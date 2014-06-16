#!/usr/bin/env bash
# This script is what you run for disaster recovery

usage() {
  echo "Usage: $0 [-s server_fqdn] [-e environment]"
  exit 1
}

check_dependencies() {
  if ! hash rumm; then #|| gem install rumm # need rackspace command line tools
    echo 'rumm not installed. Use "gem install rumm" to install rackspace CLI tools'
    exit 1
  fi

  if ! hash jq; then #|| gem install rumm # need rackspace command line tools
    echo 'jq not installed. Visit http://stedolan.github.io/jq/ to get it. Try: 
    yum install jq
      or 
    apt-get install jq'
    exit 1
  fi

  if [ ! -f ~/.rummrc ]; then
    echo 'rumm not configured. Running "rumm login" to gather rackspace credentials:'
    rumm login
  fi
}

strip() {
  # Remove " from before and after a string
  temp="${1%\"}"
  temp="${temp#\"}"
  echo "$temp"
}

test_rackspace_connection() {
  if trove list > /dev/null; then
    echo "Success testing trove connection"
  else
    echo "Unable to connect via trove, terminating"
    exit 1
  fi

  if rumm show servers > /dev/null; then
    echo "Success testing rumm connection"
  else
    echo "Unable to connect via rumm, terminating"
    exit 1
  fi

  if swiftly --auth-url='https://auth.api.rackspacecloud.com/v1.0' --auth-user=${RACKSPACE_USER} --auth-key=${RACKSPACE_API_KEY} auth ; then
    echo "Success testing swiftly connection"
  else
    echo "Unable to connect with swiftly, terminating"
    exit 1
  fi
}

check_dependencies
RACKSPACE_API_KEY=$(strip $(cat ~/.rummrc | jq '.environments.default.api_key'))
RACKSPACE_USER=$(strip $(cat ~/.rummrc | jq '.environments.default.username'))
RS_AUTH_POST="{\"auth\":{\"RAX-KSKEY:apiKeyCredentials\":{\"username\":\"$RACKSPACE_USER\", \"apiKey\":\"$RACKSPACE_API_KEY\"}}}"
RACKSPACE_TENANT_ID=$(strip $(curl -s https://identity.api.rackspacecloud.com/v2.0/tokens -X 'POST' -d "$RS_AUTH_POST" -H "Content-Type: application/json" | jq '.access.token.tenant.id' ))
ENVIRONMENT="production" #set default environment
TROVE_PWD=

echo "RACKSPACE_TENANT_ID = $RACKSPACE_TENANT_ID"
echo "RACKSPACE_USER = $RACKSPACE_USER"

while getopts ":s:e:" o; do
    case "${o}" in
        s)
            SERVER=${OPTARG}
            if echo $SERVER | grep -v '\.' > /dev/null; then
              echo "ERROR: Server must be FQDN!"
              usage
            fi
            ;;
        e) ENVIRONMENT=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${SERVER}" ] ; then
  echo "ERROR: Server name must be specified"
  usage
fi

show_settings() {
  echo "SERVER            = ${SERVER}"
  echo "ENVIRONMENT       = ${ENVIRONMENT}"
  echo "RACKSPACE_USER    = ${RACKSPACE_USER}"
  echo "RACKSPACE_API_KEY = ${RACKSPACE_API_KEY}"
}

run() {
  COMMAND="$1"
  echo "command = $COMMAND"
  echo "$COMMAND" | rumm ssh $SERVER
}

provision() {
  # Create the server, if it doesn't already exist
  if rumm show server ${SERVER}; then
    echo "Server ${SERVER} already provisioned, skipping provisioning"
  else
    echo "No server ${SERVER} is provisioned. Provisioning..."
    rumm create server --name ${SERVER} --flavor-id performance1-4
    run "touch ~/.hushlogin"
    run "ntpdate 0.north-america.pool.ntp.org"
    run "[ -f /tmp/runonce ] || apt-get -qq update && apt-get -q upgrade -y && touch /tmp/runonce"
  fi
}

puppetize() {
  IP=$(rumm show server $SERVER | grep -oE "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}")
  run "hash puppet || wget -O - http://getpuppet.deployto.me | bash"
  run "hash gem || apt-get -qq install -y rubygems"
  run "mkdir -p /etc/puppet/environments/${ENVIRONMENT}/modules"
  scp -o StrictHostKeyChecking=no example/puppet.conf-${ENVIRONMENT} root@${IP}:/etc/puppet/puppet.conf
  scp example/hiera.yaml root@${IP}:/etc/hiera.yaml
  run "[ -h /etc/puppet/hiera.yaml ] || ln -s /etc/hiera.yaml /etc/puppet/hiera.yaml"
  echo "running: rsync --recursive --verbose site root@${IP}:/etc/puppet/environments/${ENVIRONMENT}"
  rsync --recursive --verbose site root@${IP}:/etc/puppet/environments/${ENVIRONMENT}
  echo "running: rsync --recursive --verbose ./hieradata root@${IP}:/etc/puppet"
  rsync --recursive --verbose ./hieradata root@${IP}:/etc/puppet
  run "hash make || apt-get install -y make"
  run "hash git || apt-get install -y git"
  scp Puppetfile root@${IP}:/etc/puppet/
  run "hash librarian-puppet || gem install librarian-puppet"
  run "cd /etc/puppet; librarian-puppet install --path=environments/${ENVIRONMENT}/modules/"
  run "puppet apply /etc/puppet/environments/${ENVIRONMENT}/site/manifests/"
}

provision
puppetize

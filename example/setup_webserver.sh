#!/bin/bash

echo "Error messages for missing gem, git, and librarian-puppet are expected the first run"

hash gem || apt-get install rubygems -y
hash git || apt-get install -y git
hash librarian-puppet || gem install librarian-puppet
cat puppet.conf > /etc/puppet/puppet.conf
mkdir -p /etc/puppet/environments/dev/site
cat ../Puppetfile > /etc/puppet/Puppetfile
cd /etc/puppet
librarian-puppet install --path=/etc/puppet/environments/dev/modules/

# Set up hiera
rm /etc/puppet/hiera.yaml
rm /etc/hiera.yaml

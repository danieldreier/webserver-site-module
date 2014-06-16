# The base role is for basic configuration common to all servers
# Wraps other packages to avoid having to redefine these for each node
class site::roles::base (
  $timezone = 'America/Los_Angeles',
  ) {

  class { '::site::roles::base::packages': }
  class { '::site::roles::firewall': }
  #class { '::ntp': } # currently the ntp module breaks librarian-puppet
  class { 'timezone': timezone => $timezone }

  newrelic::server {
    $::hostname:
    newrelic_license_key => hiera('site::newrelic::apikey', 'NOKEY'),
  }

  class { 'apt':
    always_apt_update => true,
  }
  # Create users from hiera data
  users { 'sysadmins': }
  users { 'sites': }

  # Props to Deutsche Telekom for these hardening modules
  # github.com/TelekomLabs
  class { 'ssh_hardening::server':
    allow_root_with_key => true,
    use_pam             => true,
  }
  class { 'os_hardening': }

  # run puppet every hour at 15 minutes past the hour
  cron { 'puppet':
    command => '/usr/bin/puppet apply /etc/puppet/environments/production/site/manifests/',
    user    => root,
    minute  => '15'
  }
}

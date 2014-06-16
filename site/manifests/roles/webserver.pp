# Everything needed to set up a base webserver
# Wraps apache module, adds firewall and php setup
class site::roles::webserver (
  $vhosts = {},
  ) {
  anchor { '::site::roles::webserver': }
  Class {
    require => Anchor['::site::roles::webserver'],
  }
  class { 'apache':
    default_mods           => false,
    default_confd_files    => false,
    mpm_module             => 'prefork',
    default_vhost          => false,
    service_name           => 'apache2',
    require                => Host['example.com'],
  }

  firewall { '102 allow http':
    port   => [80],
    proto  => tcp,
    action => accept,
  }
  firewall { '103 allow https':
    port   => [443],
    proto  => tcp,
    action => accept,
  }

  include apache::mod::rewrite
  include apache::mod::deflate
  include apache::mod::status
  include apache::mod::ssl

  class { '::site::roles::webserver::php': }
  file { [ '/var/www', '/var/www/vhosts' ]:
    ensure => 'directory',
  }
  create_resources('apache::vhost', $vhosts)

  class { '::apache::mod::pagespeed':
    require => Apt::Source['mod_pagespeed'],
  }

  apt::source { 'mod_pagespeed':
    location          => 'http://dl.google.com/linux/mod-pagespeed/deb/',
    release           => 'stable',
    repos             => 'main',
    key               => '7FAC5991',
    include_src       => false
  }

  # This is a hack but needed for apache to start
  host { 'example.com':
    ensure       => 'present',
    name         => 'example.com',
    comment      => 'Apache needs this',
    host_aliases => 'www.example.com',
    ip           => $::ipaddress,
  }

  # Also a hack - this should be defined using hiera data and vhosts
  cron { 'drupal cron':
    command => '/usr/bin/drush --root=/var/www/vhosts/example.com cron',
    user    => root,
    hour    => '*/3',
  }
}

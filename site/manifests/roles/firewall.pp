# Set firewall rules common to each environment
# TODO: This seems to do the same thing as site/manifests/firewall/default.pp
class site::roles::firewall {
  class { '::firewall': }
  resources { 'firewall':
    purge => true
  }

  firewall { '100 allow ssh':
    port   => [22],
    proto  => tcp,
    action => accept,
  }

  Firewall {
    before  => Class['site::roles::firewall::post'],
    require => Class['site::roles::firewall::pre'],
  }

  class { ['site::roles::firewall::pre', 'site::roles::firewall::post']: }
}

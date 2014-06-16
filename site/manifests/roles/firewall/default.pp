# Set default firewall
# Purge existing firewall rules, then set order to ensure correct
# beginning and end rules are specified (pre / post)
class site::roles::firewall::default {
  resources { 'firewall':
    purge => true
  }

  Firewall {
    before  => Class['site::roles::firewall::post'],
    require => Class['site::roles::firewall::pre'],
  }

  class { ['site::roles::firewall::pre', 'site::roles::firewall::post']: }
}

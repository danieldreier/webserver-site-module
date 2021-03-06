# Wrap mysql client class
# This is wrapped in anticipation of wanting to do site-specific client
# configuration
class site::roles::mysql::newrelic_agent (
  $license_key   = hiera('site::newrelic::apikey', 'NOKEY'),
  $newrelic_user = 'newrelic',
  $install_path  = '/opt/newrelic_mysql'
  ){
  class { '::java': }

  # using this file type is a hack to work around a subtle bug in
  # new relic's puppet module for plugins. Apparently they only run
  # their agents as root.
  file { $install_path:
    ensure => 'directory',
    owner  => $newrelic_user,
  }
  class { '::newrelic_plugins::mysql':
    license_key  => $license_key,
    user         => $newrelic_user,
    install_path => '/opt/newrelic_mysql',
    require      => [Class['::java'],File[$install_path],User[$newrelic_user]]
  }
  user { $newrelic_user:
    ensure => 'present',
    system => true,
  }

}

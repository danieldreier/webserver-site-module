# Wrap new relic memcached client class
class site::roles::memcached::newrelic_agent (
  $license_key   = hiera('site::newrelic::apikey', 'NOKEY'),
  $newrelic_user = 'newrelic',
  $install_path  = '/opt/newrelic_memcached'
  ){

  # using this file type is a hack to work around a subtle bug in
  # new relic's puppet module for plugins. Apparently they only run
  # their agents as root.
  file { $install_path:
    ensure => 'directory',
    owner  => $newrelic_user,
  }
  class { 'newrelic_plugins::memcached_java':
    license_key  => $license_key,
    user         => $newrelic_user,
    install_path => $install_path,
    servers      => [
      {
        name          => 'memcached',
        host          => 'localhost',
        port          => 11211
      },
    ],
    require      => [User[$newrelic_user],File[$install_path]],
  }
}

node 'ubuntu-12-webserver', /^web\d+$/ {
  class { '::site::roles::base': }

#  class { '::site::roles::mysql::client': }
  class { '::site::roles::mysql::server': }
  class { '::site::roles::mysql::newrelic_agent': }
  class { '::site::roles::webserver': }
  class { '::site::roles::memcached': }
  class { '::site::roles::memcached::newrelic_agent': }
  class { '::site::roles::webserver::drush': }
  class { '::site::roles::elasticsearch': }
}
node 'ubuntu-12-dbserver', /^db\d+$/ {
  class { '::site::roles::base': }
  class { '::site::roles::mysql::server': }
}

node default {
#  remove base class from default to simplify testing with Beaker
#  class { '::site::roles::base': }
  alert 'default node, no configuration'
}

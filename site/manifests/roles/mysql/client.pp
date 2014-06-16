# Wrap mysql client class
# This is wrapped in anticipation of wanting to do site-specific client
# configuration
class site::roles::mysql::client {
  class { '::mysql::client':
    package_ensure => 'installed',
    package_name   => 'mariadb-client',
    require        => Apt::Source['mariadb'],
  }
  apt::source { 'mariadb':
    location          => 'http://mirror.jmu.edu/pub/mariadb/repo/5.5/ubuntu',
    release           => 'stable',
    repos             => 'main',
    key               => '1BB943DB',
    include_src       => true
  }

}

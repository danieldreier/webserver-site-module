# Set up a mysql server to support development
# not intended for production use
class site::roles::mysql::server (
  $root_password    = '3xX39l3x93nml3',
  $buffer_pool_size = '512M',
  $query_cache_size = '0M',
  $tmp_table_size   = '64M',
  $backup_password  = 'jjf328098uadf32',
) {
  class { '::mysql::client':
    package_ensure   => 'installed',
  }

  user { 'mysql':
    ensure           => 'present',
    comment          => 'MySQL Server',
    home             => '/var/lib/mysql',
    password         => '!',
    password_max_age => '99999',
    password_min_age => '0',
    shell            => '/bin/false',
    system           => true,
  }


  firewall { '101 allow mysql inbound':
    port   => [3306],
    proto  => tcp,
    action => accept,
  }
  create_resources('mysql::db', hiera_hash('databases'))

  mysql::db { 'dev_postaff':
    user     => 'dev_postaff',
    password => 'devdbpass',
    host     => '%',
    grant    => ['ALL', 'SUPER'],
    require  => Class['::mysql::server']
  }

  mysql::db { 'dev_joomla':
    user     => 'dev_joomla',
    password => 'devdbpass',
    host     => '%',
    grant    => ['ALL', 'SUPER'],
    require  => Class['::mysql::server']
  }

  class { '::mysql::server':
    require          => [Class['::mysql::client'],
                        Apt::Source['mariadb'],
                        User['mysql']],
    root_password    => $root_password,
    restart          => True,
    service_name     => 'mysql',
    package_name     => 'mariadb-server',
    override_options => { 'mysqld' =>
      {
      'max_connections'                 => '1024',
      'max_connections'                 => '1024',
      'innodb_buffer_pool_size'         => $buffer_pool_size,
      'innodb_additional_mem_pool_size' => '20M',
      'bind_address'                    => '0.0.0.0',
      'tmp_table_size'                  => $tmp_table_size,
      'max_heap_table_size'             => '64M',
      'key_buffer_size'                 => '32M',
      'table_cache'                     => '2000',
      'thread_cache'                    => '50',
      'open-files-limit'                => '65535',
      'table_definition_cache'          => '4096',
      'table_open_cache'                => '2048',
      'query_cache_type'                => '0',
      'query_cache_size'                => $query_cache_size,
      'innodb_flush_method'             => 'O_DIRECT',
      'innodb_flush_log_at_trx_commit'  => '1',
      'innodb_file_per_table'           => '1',
      'long_query_time'                 => '5',
      'max-allowed-packet'              => '16M',
      'max-connect-errors'              => '1000000',
      'sort-buffer-size'                => '1M',
      'read-buffer-size'                => '1M',
      'read-rnd-buffer-size'            => '8M',
      'join-buffer-size'                => '1M',
      'default-storage-engine'          => 'InnoDB',
      'innodb'                          => 'FORCE',
      'innodb-log-buffer-size'          => '64M',
      'innodb-log-file-size'            => '128M',
      'innodb-log-files-in-group'       => '2',
      'slow-query-log'                  => '1',
      'slow-query-log-file'             => '/var/lib/mysql/slow-log',
      'long-query-time'                 => '5',
      }
    },
  }

  # This is the equivalent of running mysql_secure_installation
  class { '::mysql::server::account_security':
    require => Class['::mysql::server'],
  }
  apt::source { 'mariadb':
    location    => 'http://mirror.jmu.edu/pub/mariadb/repo/10.0/ubuntu',
    release     => 'precise',
    repos       => 'main',
    key         => '1BB943DB',
    include_src => true
  }

  class { 'mysql::server::backup':
    backupuser        => 'mysqlbackup',
    backuppassword    => $backup_password,
    backupdir         => '/var/backup/mysql',
    file_per_database => true,
    require           => File['/var/backup'],
  }

  file { '/var/backup':
    ensure => 'directory',
  }


}

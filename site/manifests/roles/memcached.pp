# Everything needed to set up a base memcached
# Wraps apache module, adds firewall and php setup
class site::roles::memcached (
  $vhosts = {},
  ) {
  class { '::memcached':
    max_memory => '20%',
    listen_ip  => '127.0.0.1',
  }
}



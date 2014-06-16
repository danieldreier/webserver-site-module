# Everything needed to set up elasticsearch
class site::roles::elasticsearch {
  apt::source { 'elasticsearch_1.1':
    location    => 'http://packages.elasticsearch.org/elasticsearch/1.1/debian',
    release     => 'stable',
    repos       => 'main',
    key         => 'D88E42B4',
    include_src => false,
  }

  class { '::elasticsearch':
    config  => {
      'node'                             => {
        'name' => 'elasticsearch002'
      },
      'network'                          => {
        'host' => $::ipaddress
      },
    },
    require => [Apt::Source['elasticsearch_1.1'],
                Class['java']],
  }
}



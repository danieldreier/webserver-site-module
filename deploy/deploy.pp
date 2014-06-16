# Bootstrap librarian puppet

node default {
  # Install librarian-puppet
  package { 'rubygems': ensure => 'installed' }
  package { 'puppetmaster': ensure => 'installed' }
  service { 'puppetmaster':
    ensure  => 'running',
    require => Package['puppetmaster'],
  }
  package { 'r10k':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['rubygems'],
  }
  package { 'librarian-puppet':
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['rubygems'],
  }

  file { '/etc/puppet/Puppetfile':
    mode   => '0644',
    source => '/opt/puppet/Puppetfile',
  }
  file { '/etc/hiera.yaml':
    mode   => '0644',
    source => '/opt/puppet/deploy/hiera.yaml',
  }
  file { '/etc/puppet/hiera.yaml':
    ensure => 'link',
    target => '/etc/hiera.yaml',
  }
  file { '/etc/r10k.yaml':
    mode   => '0644',
    source => '/opt/puppet/deploy/r10k.yaml',
  }
  file { '/etc/puppet/puppet.conf':
    mode   => '0644',
    source => '/opt/puppet/deploy/puppet.conf',
  }


  # Run librarian-puppet only if Puppetfile changed
  exec { 'run librarian-puppet':
    environment => ['HOME=/root'],
    timeout     => '600',
    command     => 'librarian-puppet install',
    cwd         => '/etc/puppet',
    refreshonly => true,
    subscribe   => File['/etc/puppet/Puppetfile'],
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    require     => [ File['/etc/puppet/Puppetfile'],
                    Package['librarian-puppet'], ],
  }
}

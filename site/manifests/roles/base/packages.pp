# Install the basic packages every system needs
class site::roles::base::packages {
  case $::operatingsystem {
    'RedHat', 'CentOS': { $basic_packages = [ 'screen', 'nc', 'mtr',
                                      'iotop', 'openssh-clients', 'git' ]  }
    /^(Debian|Ubuntu)$/:{ $basic_packages = [ 'screen', 'netcat6',
                              'mtr', 'iotop', 'openssh-client', 'git',
                              'apt-file' ] }
    default: { $basic_packages = [ 'git' ]  }
  }
  package { $basic_packages: ensure => 'installed' }
}

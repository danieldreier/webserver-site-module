require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

UNSUPPORTED_PLATFORMS = ['Suse','windows','AIX','Solaris']

unless ENV['RS_PROVISION'] == 'no'
  hosts.each do |host|
    if host['platform'] =~ /debian/
      # debian 6 doesn't have gems in path by default
      on host, 'echo \'export PATH=/var/lib/gems/1.8/bin/:${PATH}\' >> ~/.bashrc'
    end
    install_puppet
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

hosts.each do |host|
  on host, 'touch /etc/puppet/hiera.yaml'
  install_package host, 'rubygems'
  install_package host, 'git'
  on host, 'hash librarian_puppet || gem install librarian-puppet --no-ri --no-rdoc'
  scp_to host, 'Puppetfile', '/etc/puppet/Puppetfile'
  scp_to host, 'example/hiera.yaml', '/etc/puppet/hiera.yaml'
  scp_to host, 'example/hiera.yaml', '/etc/hiera.yaml'
  scp_to host, 'hieradata', '/etc/puppet/hieradata'

  # super hacky way to get the fqdn facter fact working; puppet breaks without it
  on host, 'echo "127.0.0.1 $(hostname --short).example.com localhost localhost.localdomain $(hostname --short)" > /etc/hosts'

  on host, "cd /etc/puppet; librarian-puppet install"

  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  puppet_module_install(:source => "#{proj_root}/site", :module_name => 'site')
end

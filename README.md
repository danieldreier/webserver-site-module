Sample Site Module for Web Servers
==================================

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet](#setup)
    * [What this module affects](#what-this-module-affects)
    * [Getting started](#getting-started)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)
7. [Further Reading](#further-reading)

##Overview

This repository provides a sample site module defining a web server. The code
s structured as a puppet module that wraps a variety of other community
contributed puppet modules that do the setup. This module defines all
organization specific configuration.

This approach is based on http://terrarum.net/administration/puppet-infrastructure-with-r10k.html
and http://terrarum.net/administration/puppet-infrastructure.html.


##Module Description

This module configures an Apache web server and optionally a mariadb database
server to an organization's specific requirements. It uses other puppet modules
listed in the Puppetfile.

The purpose of this module is to wrap other modules; any new functionality
should generally be implemented in standalone modules. This is simply cleaner
than using a huge nodes.pp entry.

The central place where servers are defined is in the site/manifests/nodes.pp
file, where the roles each server plays are specified.

##Setup
No puppet server is needed - the module is designed to run in standalone puppet
with no exported resources. This module expects all configuration data, like
usernames, passwords, API keys, database configuration, and so on to be
configured via hiera yaml files. Those are currently in the hieradata folder.

###What this module affects

* This module assumes that the whole server is 100% managed by puppet. All existing web server configuration will be removed.
* Web server, firewall, php, backups, etc should all be managed via this tool.
* If new functionality is needed, it should be added here rather than directly on the server

###Getting started

(this section is not yet written)

##Usage

Servers based on this site module can be deployed automatically using the `provision_rackspace.sh` shell script, which is currently fairly crude. The provisioning script uses the rumm ruby gem to create a Rackspace cloud server then run a series of shell commands on it, copy files to it, and kick off a puppet run. Note that the tool currently performs NO input validation! Read it before you run it!

To provision web01.example.com for the production environment:
```bash
bash provision_rackspace.sh web01.example.com production
```

##Limitations

This module is designed to work with Ubuntu 12.04. No other distributions
or operating systems are supported. Efforts have been made to maintain CentOS
compatibility in many places, but it probably won't work without some effort.
Debian 7 will probably work but isn't specifically tested.

##Development

### Beaker Acceptance Testing
Beaker runs puppet code in a virtual machine, then tests the resulting environment. The tests are in spec/acceptance/.
If you're using RVM for ruby gem management, here's how you set up to run acceptance tests:
```
rvm gemset create odp_puppet
rvm gemset use odp_puppet
bundle install
```

To actually run the tests, simply run `bundle exec rake acceptance`. You can may want to run one of these variants:
```
# Don't destroy the vagrant VM after provisioning, but do provision a new one each run
# This will allow you to inspect the VM afterward; by default the VM is destroyed at the end of the run
BEAKER_destroy=no BEAKER_provision=yes bundle exec rake acceptance

# If you already have a running VM (from the previous command, say) use the following to
# re-run provisioning and tests against the existing VM, to save a few minutes of VM boot time.
BEAKER_destroy=no BEAKER_provision=no bundle exec rake acceptance

# Run the tets against the Debian 7.3 image instead of the default Ubuntu 12.04
BEAKER_set=debian-73-x64 bundle exec rake acceptance

# All the above combined: run tests on a debian 7.3 image and leave the resulting box running
# so you can log in and see what went wrong
BEAKER_set=debian-73-x64 BEAKER_destroy=no BEAKER_provision=yes bundle exec rake acceptance
```

To log in to a VM that results from this:
```bash
find -name Vagrantfile
./.vagrant/beaker_vagrant_files/default.yml/Vagrantfile
cd .vagrant/beaker_vagrant_files/default.yml/
vagrant ssh
```


(need more documentation on how to run this in development and on workflow)
Development in this repository should relate to puppet logic, not specific data
such as passwords or API keys. That kind of information should come from hiera
and should be stored in the hieradata folder, which should eventually be spun
off into a separate repository.

### Linting tools
Linting tools check basic syntax. This repository is configured to run a set of
linting tools when you run:
`bundle exec rake lint`

This will test whether manifests compile at all, yaml syntax, and erb template
syntax. The tests are very basic. This is the fastest set of tests.

## Further reading
http://www.slideshare.net/PuppetLabs/garethrushgrove-puppetconf
https://github.com/puppetlabs/beaker/wiki/How-to-Write-a-Beaker-Test-for-a-Module

# How hiera data is used as module parameters
http://docs.puppetlabs.com/hiera/1/puppet.html#automatic-parameter-lookup

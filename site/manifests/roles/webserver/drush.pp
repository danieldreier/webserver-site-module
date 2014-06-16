# All site-specific PHP settings
# the many augeas settings were extracted from the rackspace configuration
# those settings may not be ideal, they're just inherited
class site::roles::webserver::drush {
  php::pear::module { 'drush':
    repository  => 'pear.drush.org',
    use_package => 'no',
    alldeps     => true,
  }
}

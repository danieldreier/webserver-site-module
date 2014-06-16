# simple puppet manifest to set up a deployment workstation for windows users

package { 'ruby1.9.3':
  ensure => 'installed',
}
package { 'rubygems':
  ensure => 'installed',
}
package { 'jq':
  ensure => 'installed',
}

package { 'bundler':
    ensure   => 'installed',
    provider => 'gem',
}

package { 'rumm':
    ensure   => 'installed',
    provider => 'gem',
}

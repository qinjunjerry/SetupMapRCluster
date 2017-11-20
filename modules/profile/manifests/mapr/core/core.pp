# Class: profile::mapr::core::core
#
# This module installs/configures MapR core
#

class profile::mapr::core::core (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-core':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

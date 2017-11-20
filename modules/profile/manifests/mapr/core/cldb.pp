# Class: profile::mapr::core::cldb
#
# This module installs/configures MapR cldb
#

class profile::mapr::core::cldb (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-cldb':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}
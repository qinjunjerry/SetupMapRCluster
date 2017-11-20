# Class: profile::mapr::core::zookeeper
#
# This module installs/configures MapR zookeeper
#

class profile::mapr::core::zookeeper (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-zookeeper':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

# Class: profile::mapr::core::nodemanager
#
# This module installs/configures MapR nodemanager
#

class profile::mapr::core::nodemanager (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-nodemanager':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

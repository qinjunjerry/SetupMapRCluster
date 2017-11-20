# Class: profile::mapr::client
#
# This module installs/configures MapR client
#

class profile::mapr::client (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-client':
    ensure  => present,
    notify  => Class['profile::mapr::config_c'],
  }

}
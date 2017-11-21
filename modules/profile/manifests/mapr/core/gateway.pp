# Class: profile::mapr::core::gateway
#
# This module installs/configures MapR gateway
#

class profile::mapr::core::gateway (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-gateway':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}
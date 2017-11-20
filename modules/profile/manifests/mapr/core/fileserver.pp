# Class: profile::mapr::core::fileserver
#
# This module installs/configures MapR fileserver
#

class profile::mapr::core::fileserver (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-fileserver':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

# Class: profile::mapr::core::webserver
#
# This module installs/configures MapR webserver
#

class profile::mapr::core::webserver (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-webserver':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

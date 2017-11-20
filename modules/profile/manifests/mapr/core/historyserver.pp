# Class: profile::mapr::core::historyserver
#
# This module installs/configures MapR historyserver
#

class profile::mapr::core::historyserver (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-historyserver':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
  }

}

# Class: profile::mapr::core::posix_loopbacknfs
#
# This module installs/configures MapR loopbacknfs
#

class profile::mapr::core::posix_loopbacknfs (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-loopbacknfs':
    ensure  => present,
    notify  => Class['profile::mapr::configure_c'],
  }

}
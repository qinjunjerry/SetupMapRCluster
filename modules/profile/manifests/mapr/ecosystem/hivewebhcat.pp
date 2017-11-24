# Class: profile::mapr::ecosystem::hivewebhcat
#
# This module installs/configures MapR hivewebhcat
#

class profile::mapr::ecosystem::hivewebhcat (
) {

  require profile::mapr::configure

  package { 'mapr-hivewebhcat':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

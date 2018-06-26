# Class: profile::mapr::ecosystem::hbase
#
# This module installs/configures MapR: hbase
#

class profile::mapr::ecosystem::hbase (
) {

  package { 'mapr-hbase':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

# Class: profile::mapr::ecosystem::opentsdb
#
# This module installs/configures MapR Monitoring component: opentsdb
#

class profile::mapr::ecosystem::opentsdb (
) {

  require profile::mapr::configure_r

  package { 'mapr-opentsdb':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

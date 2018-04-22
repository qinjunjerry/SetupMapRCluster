# Class: profile::mapr::ecosystem::collectd
#
# This module installs/configures MapR Monitoring component: collectd
#

class profile::mapr::ecosystem::collectd (
) {

  require profile::mapr::configure_r

  package { 'mapr-collectd':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

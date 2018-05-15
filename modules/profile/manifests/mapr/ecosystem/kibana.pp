# Class: profile::mapr::ecosystem::kibana
#
# This module installs/configures MapR Monitoring component: kibana
#

class profile::mapr::ecosystem::kibana (
) {

  require profile::mapr::configure_r

  package { 'mapr-kibana':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

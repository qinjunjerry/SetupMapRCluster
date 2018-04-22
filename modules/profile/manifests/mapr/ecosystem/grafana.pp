# Class: profile::mapr::ecosystem::grafana
#
# This module installs/configures MapR Monitoring component: grafana
#

class profile::mapr::ecosystem::grafana (
) {

  require profile::mapr::configure_r

  package { 'mapr-grafana':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

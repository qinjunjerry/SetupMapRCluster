# Class: profile::mapr::ecosystem::fluentd
#
# This module installs/configures MapR Monitoring component: fluentd
#

class profile::mapr::ecosystem::fluentd (
) {

  require profile::mapr::configure_r

  package { 'mapr-fluentd':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

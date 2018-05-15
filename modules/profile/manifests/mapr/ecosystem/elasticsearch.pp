# Class: profile::mapr::ecosystem::elasticsearch
#
# This module installs/configures MapR Monitoring component: elasticsearch
#

class profile::mapr::ecosystem::elasticsearch (
) {

  require profile::mapr::configure_r

  package { 'mapr-elasticsearch':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

}

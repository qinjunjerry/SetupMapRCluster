# Class: profile::mapr::ecosystem::kafka
#
# This module installs/configures MapR: kafka
#

class profile::mapr::ecosystem::kafka (
) {

  package { 'mapr-kafka':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

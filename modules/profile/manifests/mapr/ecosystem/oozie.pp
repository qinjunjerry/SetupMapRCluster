# Class: profile::mapr::ecosystem::hue
#
# This module installs/configures MapR hue
#

class profile::mapr::ecosystem::hue (
) {

  require profile::mapr::configure

  package { 'mapr-hue':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

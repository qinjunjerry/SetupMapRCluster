# Class: profile::mapr::ecosystem::oozie
#
# This module installs/configures MapR oozie
#

class profile::mapr::ecosystem::oozie (
) {

  require profile::mapr::configure

  package { 'mapr-oozie':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

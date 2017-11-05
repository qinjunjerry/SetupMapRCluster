# Class: mapr_hue
#
# This module installs/configures MapR hue
#

class mapr_hue (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-hue':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }

}
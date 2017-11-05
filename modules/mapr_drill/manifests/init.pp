# Class: mapr_drill
#
# This module installs/configures MapR drill
#

class mapr_drill (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-drill':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }

}
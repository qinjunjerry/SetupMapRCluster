# Class: mapr_hive
#
# This module installs/configures MapR hive
#

class mapr_hive (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-hive':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }

}
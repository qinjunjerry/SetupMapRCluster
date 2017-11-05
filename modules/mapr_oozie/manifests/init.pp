# Class: mapr_oozie
#
# This module installs/configures MapR oozie
#

class mapr_oozie (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-oozie':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }

}
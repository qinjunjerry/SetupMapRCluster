# Class: mapr_core::historyserver
#
# This module installs/configures MapR historyserver
#

class mapr_core::historyserver (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-historyserver':
    ensure  => present,
    notify  => Class['mapr_config'],
  }

}

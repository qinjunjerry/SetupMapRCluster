# Class: mapr_resourcemanager
#
# This module installs/configures MapR resourcemanager
#

class mapr_core::resourcemanager (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-resourcemanager':
    ensure  => present,
    notify  => Class['mapr_config'],
  }

}

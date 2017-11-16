# Class: mapr_nodemanager
#
# This module installs/configures MapR nodemanager
#

class mapr_core::nodemanager (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-nodemanager':
    ensure  => present,
    notify  => Class['mapr_config::configure'],
  }

}

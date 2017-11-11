# Class: mapr_zookeeper
#
# This module installs/configures MapR zookeeper
#

class mapr_zookeeper (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-zookeeper':
    ensure  => present,
    notify  => Class['mapr_config'],
  }

}

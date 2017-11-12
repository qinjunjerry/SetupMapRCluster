# Class: mapr_fileserver
#
# This module installs/configures MapR fileserver
#

class mapr_core::fileserver (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-fileserver':
    ensure  => present,
    notify  => Class['mapr_config'],
  }

}

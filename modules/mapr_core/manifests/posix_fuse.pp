# Class: mapr_posix_fuse
#
# This module installs/configures MapR posix client basics
#

class mapr_core::posix_fuse (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-posix-client-basic':
    ensure  => present,
    notify  => Class['mapr_config_c'],
  }

}
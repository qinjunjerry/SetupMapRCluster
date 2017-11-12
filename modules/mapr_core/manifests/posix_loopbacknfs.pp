# Class: mapr_posix_loopbacknfs
#
# This module installs/configures MapR loopbacknfs
#

class mapr_core::posix_loopbacknfs (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-loopbacknfs':
    ensure  => present,
    notify  => Class['mapr_config_c'],
  }

}
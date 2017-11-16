# Class: mapr_cldb
#
# This module installs/configures MapR cldb
#

class mapr_core::cldb (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-cldb':
    ensure  => present,
    notify  => Class['mapr_config::configure'],
  }

}
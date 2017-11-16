# Class: mapr_core::core
#
# This module installs/configures MapR core
#

class mapr_core::core (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-core':
    ensure  => present,
    notify  => Class['mapr_config::configure'],
  }

}

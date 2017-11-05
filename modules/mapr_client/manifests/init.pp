# Class: mapr_client
#
# This module installs/configures MapR client
#

class mapr_client (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-client':
    ensure  => present,
    notify  => Class['mapr_config_c'],
  }

}
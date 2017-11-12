# Class: mapr_webserver
#
# This module installs/configures MapR webserver
#

class mapr_core::webserver (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-webserver':
    ensure  => present,
    notify  => Class['mapr_config'],
  }

}

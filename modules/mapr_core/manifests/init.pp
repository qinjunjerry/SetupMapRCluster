# Class: mapr_core
#
# This module installs/configures  MapR core
#

class mapr_core (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  $core_packages = [
    'mapr-zookeeper',
    'mapr-fileserver',
    'mapr-cldb',
    'mapr-nfs',
    'mapr-nodemanager',
    'mapr-resourcemanager',
    'mapr-webserver'
  ]

  $core_packages.each |$name| {
    package { $name:
      ensure  => present,
      notify  => Class['mapr_config'],
    }
  }

}
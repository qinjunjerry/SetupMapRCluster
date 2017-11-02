# Class: mapr_httpfs
#
# This module installs/configures  MapR httpfs
#

class mapr_httpfs (
) {

  require mapr_core
  require mapr_config

  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"

  package { 'mapr-httpfs':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  } 

}
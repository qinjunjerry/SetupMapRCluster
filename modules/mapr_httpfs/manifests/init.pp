# Class: mapr_httpfs
#
# This module installs/configures  MapR httpfs
#

class mapr_httpfs (
) {

  require mapr_core
  require mapr_config

  package { 'mapr-httpfs':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  } ->

  augeas { "httpfs-site.xml":
    lens => "Xml.lns",
    incl => "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml",
    changes => [
      'defnode property configuration/property[name/#text="name"] ""',
      'set $property/name/#text        "name"',
      'set $property/value/#text       "value"',
      'set $property/description/#text "description"',
    ],
  }

}
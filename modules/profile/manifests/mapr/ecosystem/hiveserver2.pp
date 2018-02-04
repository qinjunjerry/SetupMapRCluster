# Class: profile::mapr::ecosystem::hiveserver2
#
# This module installs/configures MapR hiveserver2
#

class profile::mapr::ecosystem::hiveserver2 (
) {

  include profile::mapr::cluster
  require profile::mapr::configure

  $version = fact('mapr-hive:version')
  $cfgfile = "/opt/mapr/hive/hive-$version/conf/hive-site.xml"
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node

  package { 'mapr-hiveserver2':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }
  ->
  # Needed by Hive impersonation:
  # https://maprdocs.mapr.com/52/Hive/HiveUserImpersonation-Enable.html
  profile::hadoop::xmlconf_property {
  	default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "hive.server2.enable.doAs"                   : value =>"true";
    "hive.metastore.execute.setugi"              : value =>"true";
  }

  # Needed when using mysql for hive metastore
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "hive.metastore.uris" : value => "thrift://$hive_meta_node:9083";
  }

}

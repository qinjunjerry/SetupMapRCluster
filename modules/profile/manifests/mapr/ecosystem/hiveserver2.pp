# Class: profile::mapr::ecosystem::hiveserver2
#
# This module installs/configures MapR hiveserver2
#

class profile::mapr::ecosystem::hiveserver2 (
) {

  require profile::mapr::configure

  $cfgfile = '/opt/mapr/hive/hive-2.1/conf/hive-site.xml'

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
}

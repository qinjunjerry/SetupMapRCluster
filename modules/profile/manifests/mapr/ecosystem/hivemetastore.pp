# Class: profile::mapr::ecosystem::hivemetastore
#
# This module installs/configures MapR hivemetastore
#

class profile::mapr::ecosystem::hivemetastore (
) {

  require profile::mapr::configure

  $cfgfile = '/opt/mapr/hive/hive-2.1/conf/hive-site.xml'

  package { 'mapr-hivemetastore':
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

    "hive.metastore.execute.setugi"    : value =>"true";
  }

}

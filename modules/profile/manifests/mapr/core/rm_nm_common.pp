# Class: profile::mapr::core::rm_nm_common
#
# This module manages MapR resourcemanager and nodemanager common configurations
#

class profile::mapr::core::rm_nm_common (
) {

  $cfgfile = '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml'

  # Needed by Hive/Hue impersonation:
  # https://maprdocs.mapr.com/52/Hive/HiveUserImpersonation-Enable.html
  profile::hadoop::xmlconf_property {
  	default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "hadoop.proxyuser.mapr.groups" : value =>"*";
    "hadoop.proxyuser.mapr.hosts"  : value =>"*";
  }
}

# Class: profile::mapr::ecosystem::hive_hdfs_env
#
# This module installs/configures MapR hive env on HDFS
#

class profile::mapr::ecosystem::hive_hdfs_env (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::configure
  require profile::mapr::core::cldb_ready

  # Create and chmod /user/hive/warehouse
  exec { 'mkdir /user/hive/warehouse':
    command   => "/usr/bin/hadoop fs -mkdir -p /user/hive/warehouse",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /user/hive/warehouse",
  }
  ->
  exec { 'chmod /user/hive/warehouse':
    command   => "/usr/bin/hadoop fs -chmod 777 /user/hive/warehouse",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls -d /user/hive/warehouse | grep ^drwxrwxrwx",
    before    => Class['profile::mapr::warden_restart']
  }

}

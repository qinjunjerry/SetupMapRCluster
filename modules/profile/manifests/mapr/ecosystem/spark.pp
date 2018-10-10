# Class: profile::mapr::ecosystem::spark
#
# This module installs MapR spark
# 
# In MapR 6.1, spark-defaults.conf is created not from package mapr-spark but by configure.sh. 
# So spark configuration is done in a separate class profile::mapr::ecosystem::spark_conf which requires
# class profile::mapr::configure_r

class profile::mapr::ecosystem::spark (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::configure


  include profile::mapr::cluster
  include profile::kerberos
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node


  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
  }

}

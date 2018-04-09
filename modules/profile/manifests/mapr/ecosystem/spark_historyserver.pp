# Class: mapr_spark_historyserver
#
# This module installs/configures MapR spark historyserver
#

class profile::mapr::ecosystem::spark_historyserver (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::ecosystem::spark_hdfs_env

  package { 'mapr-spark-historyserver':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
  }

  #TODO: add log4j.logger.org.spark_project.jetty.io.IdleTimeout=DEBUG
  # to capture incoming connection

}

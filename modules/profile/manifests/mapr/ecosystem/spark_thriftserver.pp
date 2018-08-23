# Class: mapr_spark_thriftserver
#
# This module installs/configures MapR spark thriftserver
#

class profile::mapr::ecosystem::spark_thriftserver (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::ecosystem::spark

  package { 'mapr-spark-thriftserver':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
  }

}

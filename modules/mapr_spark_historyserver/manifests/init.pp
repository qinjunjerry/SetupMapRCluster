# Class: mapr_spark_historyserver
#
# This module installs/configures MapR spark historyserver
#

class mapr_spark_historyserver (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user
  require mapr_spark

  package { 'mapr-spark-historyserver':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }
}
# Class: mapr_spark
#
# This module installs/configures MapR spark
#

class mapr_spark (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }
  ->
  exec { 'mkdir /apps/spark':
  	command   => "/usr/bin/hadoop fs -mkdir /apps/spark",
    logoutput => on_failure,
	unless    => "/usr/bin/hadoop fs -ls /apps/spark",
  }
  ->
  exec { 'chmod /apps/spark':
  	command   => "/usr/bin/hadoop fs -chmod 777 /apps/spark",
    logoutput => on_failure,
	unless    => "/usr/bin/hadoop fs -ls -d /apps/spark | grep ^drwxrwxrwx",
  }
}
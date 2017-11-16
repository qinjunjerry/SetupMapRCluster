# Class: mapr_spark
#
# This module installs/configures MapR spark
#

class mapr_spark (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user
  require mapr_config::configure

  $spark_home = '/opt/mapr/spark/spark-2.1.0'

  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }
  ->
  file_line { 'spark.yarn.archive':
    ensure => present,
    path   => "$spark_home/conf/spark-defaults.conf",
    line   => "spark.yarn.archive maprfs:///spark-jars.zip",
    match  => '^spark.yarn.archive',
  }

  # Configure Spark with the NodeManager Local Directory Set to MapR-FS:
  #
  # sudo -u mapr maprcli volume create -name mapr.$(hostname -f).local.spark \
  # -path /var/mapr/local/$(hostname -f)/spark -replication 1 -localvolumehost $(hostname -f)
  #
  # yarn-site.xml
  # <property>
  #   <name>yarn.nodemanager.local-dirs</name>
  #   <value>/mapr/my.cluster.com/var/mapr/local/${mapr.host}/spark</value>
  # </property>

}
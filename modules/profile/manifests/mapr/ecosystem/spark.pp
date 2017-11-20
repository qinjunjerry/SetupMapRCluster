# Class: profile::mapr::ecosystem::spark
#
# This module installs/configures MapR spark
#

class profile::mapr::ecosystem::spark (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::configure

  $spark_home = '/opt/mapr/spark/spark-2.1.0'

  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
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
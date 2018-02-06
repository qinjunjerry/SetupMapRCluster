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


  include profile::mapr::cluster
  include profile::kerberos
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node


  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
  }

  $version = fact('mapr-spark:version')
  $spark_home = "/opt/mapr/spark/spark-$version"

  file_line { 'spark.yarn.archive':
    ensure => present,
    path   => "$spark_home/conf/spark-defaults.conf",
    line   => "spark.yarn.archive maprfs:///apps/spark/spark-jars.zip",
    match  => '^spark.yarn.archive',
    require => Package['mapr-spark']
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

  # To integrate Spark-SQL with Hive
  $hive_cfgfile = "$spark_home/conf/hive-site.xml"
  profile::hadoop::xmlconf_property {
    default:
      file   => $hive_cfgfile;

    "hive.metastore.execute.setugi@spark"     : value => 'true';
    "hive.metastore.uris@spark"               : value => "thrift://$hive_meta_node:9083";
    "hive.metastore.kerberos.principal@spark" : value => "mapr/$hive_meta_node@$::profile::kerberos::default_realm";
    "spark.yarn.dist.files"                   : value => "$hive_cfgfile";
    "spark.sql.hive.metastore.version"        : value => '1.2.1';
  }

}

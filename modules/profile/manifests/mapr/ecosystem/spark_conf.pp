# Class: profile::mapr::ecosystem::spark_conf
#
# This module configures MapR spark
#

class profile::mapr::ecosystem::spark_conf (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  # require configure_r: in MapR 6.1, spark-defaults.conf is created only after configure.sh -R
  require profile::mapr::configure_r
  require profile::mapr::ecosystem::spark


  include profile::mapr::cluster
  include profile::kerberos
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node

  $version = fact('mapr-spark:version')
  $spark_home = "/opt/mapr/spark/spark-$version"
  $hive_cfgfile = "$spark_home/conf/hive-site.xml"

  file_line { 'spark.yarn.archive':
    ensure  => present,
    path    => "$spark_home/conf/spark-defaults.conf",
    line    => "spark.yarn.archive maprfs:///apps/spark-jars.zip",
    match   => '^spark.yarn.archive',
  }

  file_line { 'spark.yarn.dist.files':
    ensure  => present,
    path    => "$spark_home/conf/spark-defaults.conf",
    line    => "spark.yarn.dist.files $hive_cfgfile",
    match   => '^spark.yarn.dist.files',
  }

  file_line { 'spark.sql.hive.metastore.version':
    ensure  => present,
    path    => "$spark_home/conf/spark-defaults.conf",
    line    => "spark.sql.hive.metastore.version 1.2.1",
    match   => '^spark.sql.hive.metastore.version',
  }  

  # To integrate Spark-SQL with Hive
  # TODO: check security flag
  profile::hadoop::xmlconf_property {
    default:
      file   => $hive_cfgfile;

    "hive.metastore.execute.setugi@spark"     : value => 'true';
    "hive.metastore.uris@spark"               : value => "thrift://$hive_meta_node:9083";
    "hive.metastore.kerberos.principal@spark" : value => "mapr/$hive_meta_node@$::profile::kerberos::default_realm";
  }

}

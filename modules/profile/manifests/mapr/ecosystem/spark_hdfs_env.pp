# Class: profile::mapr::ecosystem::spark_hdfs_env
#
# This module installs/configures MapR spark env on HDFS
#

class profile::mapr::ecosystem::spark_hdfs_env (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::ecosystem::spark
  require profile::mapr::configure
  require profile::mapr::core::cldb_ready

  $version = fact('mapr-spark_version')
  $spark_home = "/opt/mapr/spark/spark-$version"

  package { 'zip':
    ensure => installed,
  }

  # Create and chmod /apps/spark
  exec { 'mkdir /apps/spark':
    command   => "/usr/bin/hadoop fs -mkdir -p /apps/spark",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /apps/spark",
  }
  ->
  exec { 'chmod /apps/spark':
    command   => "/usr/bin/hadoop fs -chmod 777 /apps/spark",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls -d /apps/spark | grep ^drwxrwxrwx",
  }
  # Configure Spark JAR Location (Spark 2.0.1 and later)
  ->
  exec { "zip $spark_home/jars/*":
    # keep '/' before $spark_home: required by puppet validation
    cwd       => "/$spark_home/jars",
    command   => "/usr/bin/zip $spark_home/spark-jars.zip ./*",
    # keep '/' before $spark_home: required by puppet validation
    creates   => "/$spark_home/spark-jars.zip",
    logoutput => on_failure,
    require   => Package['zip'],
  }
  ->
  exec { 'upload spark-jars.zip':
    command   => "/usr/bin/hadoop fs -put $spark_home/spark-jars.zip /apps/spark",
    logoutput => on_failure,
    unless    => '/usr/bin/hadoop fs -ls /apps/spark/spark-jars.zip',
    before    => Class['profile::mapr::warden_restart'],
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

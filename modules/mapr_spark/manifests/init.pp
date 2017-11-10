# Class: mapr_spark
#
# This module installs/configures MapR spark
#

class mapr_spark (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user

  $spark_home = '/opt/mapr/spark/spark-2.1.0'

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
  ->
  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }
  # Configure Spark JAR Location (Spark 2.0.1 and later)
  ->
  exec { "zip $spark_home/jars/*":
    cwd       => '$spark_home/jars',
    command   => 'zip $spark_home/spark-jars.zip ./*',
    creates   => '$spark_home/spark-jars.zip',
    logoutput => on_failure,
  }
  ->
  exec { 'upload spark-jars.zip':
    command   => "hadoop fs -put $spark_home/spark-jars.zip /user/mapr/",
    logoutput => on_failure,
    unless    => 'hadoop fs -ls /user/mapr/spark-jars.zip',
  }
  ->
  file_line { 'spark.yarn.archive':
    ensure => present,
    path   => "$spark_home/conf/spark-defaults.conf",
    line   => "spark.yarn.archive maprfs:///user/mapr/spark-jars.zip",
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
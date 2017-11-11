# Class: mapr_spark
#
# This module installs/configures MapR spark
#

class mapr_spark (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user
  require mapr_config

  $spark_home = '/opt/mapr/spark/spark-2.1.0'
  $host_name = fact('networking.hostname')

  exec { "kinit mapr/$host_name":
    command   => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr/$host_name",
    logoutput => on_failure,
    require   => File['/opt/mapr/conf/mapr.keytab'],
  }
  ->
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
  ->
  package { 'mapr-spark':
    ensure  => present,
    notify  => Class['mapr_config_r'],
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
    command   => "/usr/bin/hadoop fs -put $spark_home/spark-jars.zip /var/mapr/",
    logoutput => on_failure,
    unless    => '/usr/bin/hadoop fs -ls /var/mapr/spark-jars.zip',
  }
  ->
  file_line { 'spark.yarn.archive':
    ensure => present,
    path   => "$spark_home/conf/spark-defaults.conf",
    line   => "spark.yarn.archive maprfs:///var/mapr/spark-jars.zip",
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
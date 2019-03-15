# Class: profile::mapr::ecosystem::tez
#
# This module installs/configures MapR tez
#

class profile::mapr::ecosystem::tez (
) {

  require profile::mapr::core::cldb_ready
  require profile::mapr::ecosystem::hiveserver2


  $version = fact('mapr-tez:version')
  $hive_version = fact('mapr-hive:version')
  $hive_envfile = "/opt/mapr/hive/hive-$hive_version/conf/hive-env.sh"
  $hive_cfgfile = "/opt/mapr/hive/hive-$hive_version/conf/hive-site.xml"


  package { 'mapr-tez':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

  # Create and chmod /apps/tez
  exec { 'mkdir /apps/tez':
    command   => "/usr/bin/hadoop fs -mkdir -p /apps/tez",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /apps/tez",
  }
  ->
  exec { 'upload tez to /apps/tez':
    command   => "/usr/bin/hadoop fs -put /opt/mapr/tez/tez-$version /apps/tez",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /apps/tez/tez-$version",
  }
  ->
  exec { 'chmod /apps/tez':
    command   => "/usr/bin/hadoop fs -chmod -R 755 /apps/tez",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls -d /apps/tez | grep ^drwxr-xr-x",
  }
  ->
 file { $hive_envfile:
    ensure  => 'present',
    replace => 'no', # this is the important property
    content => "",
    mode    => '0644',
  }
  ->
  file_line {'TEZ_CONF_DIR in hive-env.sh':
  	ensure   => 'present',
  	path     => $hive_envfile,
    line     => "export TEZ_CONF_DIR=/opt/mapr/tez/tez-$version/conf",
  	match    => '^\s*export TEZ_CONF_DIR\=',
  }  
  ->
  file_line {'TEZ_JARS in hive-env.sh':
  	ensure   => 'present',
  	path     => $hive_envfile,
    line     => "export TEZ_JARS=/opt/mapr/tez/tez-$version/*:/opt/mapr/tez/tez-$version/lib/*",
  	match    => '^\s*export TEZ_JARS\=',
  }
  ->
  file_line {'HADOOP_CLASSPATH in hive-env.sh':
  	ensure   => 'present',
  	path     => $hive_envfile,
    line     => 'export HADOOP_CLASSPATH=$TEZ_CONF_DIR:$TEZ_JARS:$HADOOP_CLASSPATH',
  	match    => '^\s*export HADOOP_CLASSPATH\=',
  }
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => $hive_cfgfile,
      notify  => Class['profile::mapr::configure_r'];

    "hive.execution.engine"  : value => "tez";
  }
  
  if versioncmp($version, '0.9') < 0 {
	  profile::hadoop::xmlconf_property {
	    default:
	      file   => $hive_cfgfile,
	      notify  => Class['profile::mapr::configure_r'];

	    "hive.exec.pre.hooks"    : value => 'org.apache.hadoop.hive.ql.hooks.ATSHook';
	    "hive.exec.post.hooks"   : value => 'org.apache.hadoop.hive.ql.hooks.ATSHook';
	  }
	}

}
# Class: profile::mapr::ecosystem::tez
#
# This module installs/configures MapR tez
#

class profile::mapr::ecosystem::tez (
) {

  require profile::mapr::core::cldb_ready
  require profile::mapr::ecosystem::hiveserver2

  include profile::mapr::cluster

  # append domain name to the hostname if not already done
  $timelineserver = join ( 
      split($profile::mapr::cluster::timelineserver,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  $hostname = fact('networking.fqdn')
  $version = fact('mapr-tez:version')
  $cfgfile = "/opt/mapr/tez/tez-$version/conf/tez-site.xml"

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
    replace => 'no', # this is an important property
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
  
  if versioncmp($version, '0.9') >= 0 {
	  profile::hadoop::xmlconf_property {
	    default:
	      file   => $hive_cfgfile,
	      notify  => Class['profile::mapr::configure_r'];

	    "hive.exec.pre.hooks"    : value => 'org.apache.hadoop.hive.ql.hooks.ATSHook';
	    "hive.exec.post.hooks"   : value => 'org.apache.hadoop.hive.ql.hooks.ATSHook';
	  }
	}

  # Hive-Tez-UI steps overview:
  # 1. install mapr-timelineserver (warden/role files), (who?) start timeline server and listening on 8190
  # 2. on all hive nodes, configure (via configure.sh) yarn-site.xml to point to timeline server, optionally configure kerberos
  # 3. on tez node, configure tez/tomcat to point to timelineserver and RM in configs.env, start tez-ui server.
  # 4. on tez node, configure tez-site.xml to point to tez-ui server

  # tez-ui
  archive { "/opt/mapr/tez/tez-$version/tomcat/tomcat.tar.gz":
    extract      => true,
    extract_path => "/opt/mapr/tez/tez-$version/tomcat",
    creates      => "/opt/mapr/tez/tez-$version/tomcat/apache-tomcat-9.0.1",
    cleanup      => false,
    require      => Package['mapr-tez'],
  } 
  ->
  exec { 'chmod TEZ_HOME/tomcat':
    command   => "/usr/bin/chown -R mapr:mapr /opt/mapr/tez/tez-$version/tomcat",
    logoutput => on_failure,
    unless    => "/usr/bin/ls -d /opt/mapr/tez/tez-$version/tomcat/apache-tomcat-9.0.1 | grep 'mapr mapr'",
  }
  ->
  file_line {'TIME_LINE_BASE_URL in tez-ui/config/configs.env':
    ensure   => 'present',
    path     => "/opt/mapr/tez/tez-$version/tomcat/apache-tomcat-9.0.1/webapps/tez-ui/config/configs.env",
    line     => "    timeline: \'https://$timelineserver:8190\',",
    match    => '^\s*timeline:',
  }
  ->
  # TODO: support RM HA
  file_line {'RM_WEB_URL in tez-ui/config/configs.env':
    ensure   => 'present',
    path     => "/opt/mapr/tez/tez-$version/tomcat/apache-tomcat-9.0.1/webapps/tez-ui/config/configs.env",
    line     => "    rm: 'https://node69.ucslocal:8090',",
    match    => '^\s*rm:',
  }
  ->
  exec { 'startup TEZ-UI':
    command   => "/opt/mapr/tez/tez-$version/tomcat/apache-tomcat-9.0.1/bin/startup.sh",
    user      => 'mapr',
    logoutput => on_failure,
    unless    => "/usr/bin/ps -ef | grep catalina.base=/opt/mapr/tez/tez-0.9/tomcat/apache-tomcat-9.0.[1]",
  } 
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => $cfgfile;

    "tez.history.logging.service.class" : value => 'org.apache.tez.dag.history.logging.ats.ATSHistoryLoggingService';
    "tez.tez-ui.history-url.base"       : value => "http://$hostname:9383/tez-ui/";
  }

}
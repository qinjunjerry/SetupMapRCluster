# Class: profile::mapr::ecosystem::hivemetastore
#
# This module installs/configures MapR hivemetastore
#

class profile::mapr::ecosystem::hivemetastore (
) {

  include profile::mapr::cluster
  include profile::kerberos
  require profile::mapr::configure


  $version = fact('mapr-hive:version')
  $cfgfile = "/opt/mapr/hive/hive-$version/conf/hive-site.xml"

  $mysql_node     = $profile::mapr::cluster::mysql_node
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node
  $metastore_db   = regsubst($profile::mapr::cluster::cluster_name, '\.', '_', 'G')
  $hostname = fact('networking.fqdn')

  package { 'mapr-hivemetastore':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }
  ->
  # Needed by Hive impersonation:
  # https://maprdocs.mapr.com/52/Hive/HiveUserImpersonation-Enable.html
  profile::hadoop::xmlconf_property {
    default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "hive.metastore.execute.setugi"    : value =>"true";
  }

  # Configure MySQL for hive metastore
  ->
  package { 'mysql-connector-java':
    ensure  => present,
    require => Package['mapr-hivemetastore'];
  }
  ->
  exec { 'link mysql-connector-jar.jar':
    command   => "/usr/bin/ln -s /usr/share/java/mysql-connector-java.jar /opt/mapr/hive/hive-$version/lib/mysql-connector-java.jar",
    logoutput => on_failure,
    creates   => "/opt/mapr/hive/hive-$version/lib/mysql-connector-java.jar",
  }
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "javax.jdo.option.ConnectionURL"        : value => "jdbc:mysql://$mysql_node/metastore_$metastore_db";
    "javax.jdo.option.ConnectionDriverName" : value => 'com.mysql.jdbc.Driver';
    "javax.jdo.option.ConnectionUserName"   : value => 'hive';
    "javax.jdo.option.ConnectionPassword"   : value => 'password';
    "hive.metastore.uris"                   : value => "thrift://$hive_meta_node:9083";
  }
  ->
  exec { 'initSchema':
    command   => "/opt/mapr/hive/hive-$version/bin/schematool -dbType mysql -initSchema",
    logoutput => on_failure,
    unless    => "/opt/mapr/hive/hive-2.1/bin/schematool -dbType mysql -info",
  }

  # Configure Hive metastore to use kerberos
  
  if $profile::mapr::cluster::kerberos == true {
 
    profile::hadoop::xmlconf_property {
      default:
        file    => $cfgfile,
        require => Package['mapr-hivemetastore'],
        notify  => Class['profile::mapr::warden_restart'];

      "hive.metastore.kerberos.keytab.file"   : value => '/opt/mapr/conf/mapr.keytab';
      "hive.metastore.kerberos.principal"     : value => "mapr/$hostname@$::profile::kerberos::default_realm";
    }
    ->
    file_line {'MAPR_HIVE_LOGIN_OPTS in /opt/mapr/conf/env.sh':
      ensure   => 'present',
      path     => '/opt/mapr/conf/env.sh',
      line     => '    MAPR_HIVE_LOGIN_OPTS="-Dhadoop.login=hybrid"',
      match    => '^\s+MAPR_HIVE_LOGIN_OPTS\="-Dhadoop.login=maprsasl"',
      notify   => Class['profile::mapr::warden_restart'],
    }
    ->
    file_line {'MAPR_HIVE_SERVER_LOGIN_OPTS in /opt/mapr/conf/env.sh':
      ensure   => 'present',
      path     => '/opt/mapr/conf/env.sh',
      line     => '    MAPR_HIVE_SERVER_LOGIN_OPTS="-Dhadoop.login=hybrid"',
      match    => '^\s+MAPR_HIVE_SERVER_LOGIN_OPTS\="-Dhadoop.login=maprsasl_keytab"',
      notify   => Class['profile::mapr::warden_restart'],
    }
    ->
    file_line { "HADOOP_OPTS in /opt/mapr/hive/hive-$version/bin/ext/beeline.sh":
      ensure   => 'present',
      path     => "/opt/mapr/hive/hive-$version/bin/ext/beeline.sh",
      line     => '  export HADOOP_OPTS="$HADOOP_OPTS ${KERBEROS_LOGIN_OPTS}"',
      match    => '^\s+export HADOOP_OPTS\=',
    }

  }

}

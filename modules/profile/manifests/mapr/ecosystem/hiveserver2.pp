# Class: profile::mapr::ecosystem::hiveserver2
#
# This module installs/configures MapR hiveserver2
#

class profile::mapr::ecosystem::hiveserver2 (
) {

  include profile::mapr::cluster
  include profile::kerberos
  require profile::mapr::configure

  $version = fact('mapr-hive:version')
  $cfgfile = "/opt/mapr/hive/hive-$version/conf/hive-site.xml"

  # append domain name to hostname if not already done
  $hive_meta_node = $profile::mapr::cluster::hive_meta_node =~ /.+\..+/ ? {
    true    => $profile::mapr::cluster::hive_meta_node,
    default => "${profile::mapr::cluster::hive_meta_node}.${profile::mapr::prereq::domain}" 
  }

  $hostname = fact('networking.fqdn')

  package { 'mapr-hiveserver2':
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

    "hive.server2.enable.doAs"                   : value =>"true";
    "hive.metastore.execute.setugi@hs2"          : value =>"false";
  }

  # Needed when using mysql for hive metastore
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => $cfgfile,
      notify => Class['profile::mapr::warden_restart'];

    "hive.metastore.uris@hs2" : value => "thrift://$hive_meta_node:9083";
  }

  # Configure Hive Server2 to use kerberos
  if $profile::mapr::cluster::kerberos == true {
  
    profile::hadoop::xmlconf_property {
      default:
        file    => $cfgfile,
        require => Package['mapr-hiveserver2'],
        notify  => Class['profile::mapr::warden_restart'];

      "hive.server2.authentication"                   : value => 'KERBEROS';
      "hive.server2.authentication.kerberos.keytab"   : value => '/opt/mapr/conf/mapr.keytab';
      "hive.server2.authentication.kerberos.principal": value => "mapr/$hostname@$::profile::kerberos::default_realm";
      "hive.metastore.kerberos.principal@hs2"         : value => "mapr/$hive_meta_node@$::profile::kerberos::default_realm";
    }
    ->
    file_line { 'MAPR_HIVE_LOGIN_OPTS in /opt/mapr/conf/env.sh@hs2':
      ensure   => 'present',
      path     => '/opt/mapr/conf/env.sh',
      line     => '    MAPR_HIVE_LOGIN_OPTS="-Dhadoop.login=hybrid"',
      match    => '^\s+MAPR_HIVE_LOGIN_OPTS\="-Dhadoop.login=maprsasl"',
      notify   => Class['profile::mapr::warden_restart'],
    }
    ->
    file_line { 'MAPR_HIVE_SERVER_LOGIN_OPTS in /opt/mapr/conf/env.sh@hs2':
      ensure   => 'present',
      path     => '/opt/mapr/conf/env.sh',
      line     => '    MAPR_HIVE_SERVER_LOGIN_OPTS="-Dhadoop.login=hybrid"',
      match    => '^\s+MAPR_HIVE_SERVER_LOGIN_OPTS\="-Dhadoop.login=maprsasl_keytab"',
      notify   => Class['profile::mapr::warden_restart'],
    }
    ->
    file_line { "HADOOP_OPTS in /opt/mapr/hive/hive-$version/bin/ext/beeline.sh@hs2":
      ensure   => 'present',
      path     => "/opt/mapr/hive/hive-$version/bin/ext/beeline.sh",
      line     => '  export HADOOP_OPTS="$HADOOP_OPTS ${KERBEROS_LOGIN_OPTS}"',
      match    => '^\s+export HADOOP_OPTS\=',
    }

  }

}

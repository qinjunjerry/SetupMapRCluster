# Class: profile::mapr::ecosystem::httpfs
#
# This module installs/configures MapR httpfs
#

class profile::mapr::ecosystem::httpfs (
) {

  require profile::mapr::configure

  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"
  $hostname = fact('networking.hostname')

  package { 'mapr-httpfs':
    ensure  => present,
  }
  ->
  profile::hadoop::xmlconf_property {
  	default: file=>$file;
    "httpfs.authentication.type"                     : value =>"kerberos";
    "httpfs.hadoop.authentication.type"              : value =>"kerberos";
    "httpfs.hadoop.authentication.kerberos.principal": value =>"mapr/$hostname";
    "httpfs.hadoop.authentication.kerberos.keytab"   : value =>"/opt/mapr/conf/mapr.keytab";
    "httpfs.authentication.kerberos.name.rules"      : value =>"DEFAULT";
  }

}
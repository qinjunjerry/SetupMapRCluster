# Class: mapr_httpfs
#
# This module installs/configures  MapR httpfs
#

class mapr_httpfs (
) {

  require mapr_core
  require mapr_config

  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"
  $hostname = fact('networking.hostname')

  package { 'mapr-httpfs':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  } ->
  file { "/opt/mapr/conf/httpfs-$hostname.keytab":
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0600',
    source => "puppet:///modules/mapr_httpfs/httpfs-$hostname.keytab",
  } ->
  mapr_util::hadoop_xml_conf {
  	default: file=>$file;
    "httpfs.authentication.type"                     : value =>"kerberos";
    "httpfs.hadoop.authentication.type"              : value =>"kerberos";
    "httpfs.hadoop.authentication.kerberos.principal": value =>"mapr/$hostname";
    "httpfs.hadoop.authentication.kerberos.keytab"   : value =>"/opt/mapr/conf/httpfs-$hostname.keytab";
    "httpfs.authentication.kerberos.name.rules"      : value =>"DEFAULT";
  }

}
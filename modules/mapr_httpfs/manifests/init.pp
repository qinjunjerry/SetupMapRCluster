# Class: mapr_httpfs
#
# This module installs/configures  MapR httpfs
#

class mapr_httpfs (
) {

  require mapr_config

  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"
  $hostname = fact('networking.hostname')

  package { 'mapr-httpfs':
    ensure  => present,
    #notify  => Class['mapr_config_r'],
  }
  ->
  mapr_util::hadoop_xml_conf {
  	default: file=>$file;
    "httpfs.authentication.type"                     : value =>"kerberos";
    "httpfs.hadoop.authentication.type"              : value =>"kerberos";
    "httpfs.hadoop.authentication.kerberos.principal": value =>"mapr/$hostname";
    "httpfs.hadoop.authentication.kerberos.keytab"   : value =>"/opt/mapr/conf/mapr.keytab";
    "httpfs.authentication.kerberos.name.rules"      : value =>"DEFAULT";
  }

}
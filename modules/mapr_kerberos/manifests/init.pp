# Class: mapr_kerberos
#
# This module configures kerberos
#

class mapr_kerberos (

) {

  require mapr_pre
  require mapr_sasl

  $hostname = fact('networking.hostname')

  file_line { 'set-crypto.policy':
    ensure => present,
    path   => "/usr/java/default/jre/lib/security/java.security",
    line   => "crypto.policy=unlimited",
    match  => '^crypto.policy\=',
  }

  package { 'krb5-workstation':
    ensure => installed,
  }

  file { '/etc/krb5.conf':
    ensure => file,
    source => "puppet:///modules/mapr_kerberos/krb5.conf",
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/opt/mapr/conf/mapr.keytab':
    ensure => file,
    source => "puppet:///modules/mapr_kerberos/$hostname/mapr.keytab",
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0600',
  }
}
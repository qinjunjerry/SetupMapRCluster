# Class: mapr_config::kerberos
#
# This module configures kerberos
#

class mapr_config::kerberos (
  $cluster_name   = $mapr_config::cluster_name,
) inherits mapr_config {

  require mapr_pre
  require mapr_config::sasl

  $hostname = fact('networking.hostname')
  $inputdir = '/MapRSetup/input'

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
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => epp("$inputdir/krb5.conf.epp"),
  }

  file { '/opt/mapr/conf/mapr.keytab':
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0600',
    # Puppet will use the first source that exists
    source => [
      "$inputdir/$hostname/mapr.keytab",
      "$inputdir/mapr.keytab",
    ]
  }
}
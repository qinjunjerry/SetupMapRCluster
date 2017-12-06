# Class: kerberos::kdc
#
# This module installs/configures Kerberos KDC (Key Distribution Center)
#

class profile::kerberos::kdc (
) {
  include profile::kerberos

  package { 'krb5-server':
    ensure  => present,
  }
  ->
  file { '/etc/krb5.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp("profile/kerberos/krb5.conf.epp"),
  }
  ->
  file { '/var/kerberos/krb5kdc/kdc.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp("profile/kerberos/kdc.conf.epp"),
  }
  ->
  package { 'haveged':
    ensure  => present,
    require => Class['profile::redhat::epel'],
  }
  ->
  service { 'haveged':
    enable => true,
    ensure => running,
  }
  ->
  # TODO: add master password in hiera
  exec { 'create kdc database':
    command => '/usr/sbin/kdb5_util create -s -P mapr',
    creates => '/var/kerberos/krb5kdc/principal',
  }
  ->
  file { '/var/kerberos/krb5kdc/kadm5.acl':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "*/admin@$profile::kerberos::default_realm  *",
  }
  ->
  exec { 'create principal mapr/admin':
    command => '/usr/sbin/kadmin.local -q "addprinc  -pw admin mapr/admin"',
    unless  => '/usr/sbin/kadmin.local -q "listprincs" | grep mapr/admin@',
  }
  ->
  exec { 'create principal mapr':
    command => '/usr/sbin/kadmin.local -q "addprinc  -pw admin mapr"',
    unless  => '/usr/sbin/kadmin.local -q "listprincs" | grep mapr@',
  }
  ->
  exec { 'create principal root':
    command => '/usr/sbin/kadmin.local -q "addprinc  -pw admin root"',
    unless  => '/usr/sbin/kadmin.local -q "listprincs" | grep root@',
  }
  ->
  service { 'krb5kdc':
    enable => true,
    ensure => running,
  }
  ->
  service { 'kadmin':
    enable => true,
    ensure => running,
  }
}

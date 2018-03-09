# Class: profile::mapr::kerberos
#
# This module configures kerberos
#

class profile::mapr::kerberos (
) {

  include profile::mapr::cluster

  if $profile::mapr::cluster::kerberos == true {
    require profile::mapr::prereq
    require profile::mapr::sasl

    include profile::kerberos

    $hostname = fact('networking.fqdn')

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
      content => epp("profile/kerberos/krb5.conf.epp"),
    }

    file { '/opt/mapr/conf/mapr.keytab':
      ensure => file,
      owner  => 'mapr',
      group  => 'mapr',
      mode   => '0600',
      # Puppet will use the first source that exists
      source => [
        "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/mapr.keytab",
        "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/mapr.keytab",
      ]
    }
  }
}

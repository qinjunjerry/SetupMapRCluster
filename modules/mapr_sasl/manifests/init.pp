# Class: mapr_sasl
#
# This module configures MapR SASL
#

class mapr_sasl (

) {

  require mapr_core

  file { '/opt/mapr/conf/cldb.key':
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0600',
    source => "puppet:///modules/mapr_sasl/cldb.key",
  }

  file { '/opt/mapr/conf/maprserverticket':
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0600',
    source => "puppet:///modules/mapr_sasl/maprserverticket",
  }

  file { '/opt/mapr/conf/ssl_keystore':
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0400',
    source => "puppet:///modules/mapr_sasl/ssl_keystore",
  }

  file { '/opt/mapr/conf/ssl_truststore':
    ensure => file,
    owner  => 'mapr',
    group  => 'mapr',
    mode   => '0444',
    source => "puppet:///modules/mapr_sasl/ssl_truststore",
  }

}
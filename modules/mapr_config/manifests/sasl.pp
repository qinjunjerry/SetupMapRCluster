# Class: mapr_config::sasl
#
# This module configures MapR SASL
#

class mapr_config::sasl (
) {

  require mapr_core::core

  include mapr_config

  $inputdir = "/MapRSetup/input"

  file {
    default:
      ensure => file,
      owner  => 'mapr',
      group  => 'mapr',
      mode   => '0600';
    '/opt/mapr/conf/cldb.key'        : source  => "$inputdir/cldb.key";
    '/opt/mapr/conf/maprserverticket': content => epp("$inputdir/maprserverticket.epp");
    '/opt/mapr/conf/ssl_keystore'    : source  => "$inputdir/ssl_keystore",  mode => '0400';
    '/opt/mapr/conf/ssl_truststore'  : source  => "$inputdir/ssl_truststore",mode => '0444';
  }

}
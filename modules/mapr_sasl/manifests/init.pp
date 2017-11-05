# Class: mapr_sasl
#
# This module configures MapR SASL
#

class mapr_sasl (

) {

  require mapr_core

  $inputdir = "/MapRSetup/input"

  file {
    default:
      ensure => file,
      owner  => 'mapr',
      group  => 'mapr',
      mode   => '0600';
    '/opt/mapr/conf/cldb.key'        : source => "$inputdir/cldb.key";
    '/opt/mapr/conf/maprserverticket': source => "$inputdir/maprserverticket";
    '/opt/mapr/conf/ssl_keystore'    : source => "$inputdir/ssl_keystore",  mode => '0400';
    '/opt/mapr/conf/ssl_truststore'  : source => "$inputdir/ssl_truststore",mode => '0444';
  }

}
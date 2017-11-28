# Class: profile::mapr::sasl
#
# This module configures MapR SASL
#

class profile::mapr::sasl (
) {

  require profile::mapr::core::core

  include profile::mapr::cluster

  file {
    default:
      ensure => file,
      owner  => 'mapr',
      group  => 'mapr',
      mode   => '0600';
    '/opt/mapr/conf/cldb.key'        : source  => "$::base_dir/inputfiles/cldb.key";
    '/opt/mapr/conf/maprserverticket': source  => "$::base_dir/inputfiles/maprserverticket";
    '/opt/mapr/conf/ssl_keystore'    : source  => "$::base_dir/inputfiles/ssl_keystore",  mode => '0400';
    '/opt/mapr/conf/ssl_truststore'  : source  => "$::base_dir/inputfiles/ssl_truststore",mode => '0444';
  }

}

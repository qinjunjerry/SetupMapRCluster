# Class: mapr_config::sasl
#
# This module configures MapR SASL
#

class mapr_config::sasl (
) {

  require mapr_core::core

  include mapr_config

  file {
    default:
      ensure => file,
      owner  => 'mapr',
      group  => 'mapr',
      mode   => '0600';
    '/opt/mapr/conf/cldb.key'        : source  =>     "$::base_dir/input/cldb.key";
    '/opt/mapr/conf/maprserverticket': content => epp("$::base_dir/input/maprserverticket.epp");
    '/opt/mapr/conf/ssl_keystore'    : source  =>     "$::base_dir/input/ssl_keystore",  mode => '0400';
    '/opt/mapr/conf/ssl_truststore'  : source  =>     "$::base_dir/input/ssl_truststore",mode => '0444';
  }

}
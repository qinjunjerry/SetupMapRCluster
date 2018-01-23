# Class: profile::mapr::sasl
#
# This module configures MapR SASL
#

class profile::mapr::sasl (
) {

  if $profile::mapr::cluster::secure == true {
    require profile::mapr::core::core

    include profile::mapr::cluster

    $hostname = fact('networking.fqdn')

    file {
      default:
        ensure => file,
        owner  => 'mapr',
        group  => 'mapr',
        mode   => '0600';
      '/opt/mapr/conf/cldb.key'        : source => "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/cldb.key";
      '/opt/mapr/conf/maprserverticket': source => "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/maprserverticket";
      '/opt/mapr/conf/ssl_keystore'    : mode   => '0400', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_keystore",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_keystore",
      ];
      '/opt/mapr/conf/ssl_truststore'  : mode   => '0444', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_truststore",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_truststore",
      ];
    }
  }

}

# Class: profile::mapr::sasl
#
# This module configures MapR SASL
#

class profile::mapr::sasl (
) {

  include profile::mapr::cluster

  if $profile::mapr::cluster::secure == true {
    require profile::mapr::core::core

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

      # p12 files
      '/opt/mapr/conf/ssl_keystore.p12'    : mode   => '0400', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_keystore.p12",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_keystore.p12",
      ];
      '/opt/mapr/conf/ssl_truststore.p12'  : mode   => '0444', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_truststore.p12",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_truststore.p12",
      ];

      # pem files
      '/opt/mapr/conf/ssl_keystore.pem'    : mode   => '0400', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_keystore.pem",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_keystore.pem",
      ];
      '/opt/mapr/conf/ssl_truststore.pem'  : mode   => '0444', source => [
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/$hostname/ssl_truststore.pem",
            "$::base_dir/inputfiles/$profile::mapr::cluster::cluster_name/ssl_truststore.pem",
      ];


    }
  }

}

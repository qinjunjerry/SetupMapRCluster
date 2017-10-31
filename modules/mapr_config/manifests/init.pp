# Class: mapr_config
#
# This module generates configure_mapr.sh and runs it
#

class mapr_config (
  $cluster_name   = $mapr_config::cluster_name,  
  $cldb_node_list = $mapr_config::cldb_node_list,
  $zk_node_list   = $mapr_config::zk_node_list,  
  $secure         = $mapr_config::secure, 
  $kerberos       = $mapr_config::kerberos, 
  $genkey_opts    = $mapr_config::genkey_opts, 
  $refreshonly    = $mapr_config::refreshonly, 
  $disk_list      = $mapr_config::disk_list, 
) {

  require mapr_sasl
  require mapr_kerberos
  
  # generate configure_mapr.sh
  file { '/MapRSetup/configure_mapr.sh':
    ensure  => present,
    content => epp('mapr_config/configure_mapr.sh.epp'),
  } ~>
  # run configure_mapr.sh
  exec { 'run configure_mapr.sh':
    command     => '/bin/sh /MapRSetup/configure_mapr.sh',
    refreshonly => true,
  } 

}
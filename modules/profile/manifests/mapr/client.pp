# Class: profile::mapr::client
#
# This module installs/configures MapR client
#

class profile::mapr::client (
  $cluster_name   = $profile::mapr::cluster::cluster_name,
  $cldb_node_list = $profile::mapr::cluster::cldb_node_list,
  $zk_node_list   = $profile::mapr::cluster::zk_node_list,
  $historyserver  = $profile::mapr::cluster::historyserver,
  $secure         = $profile::mapr::cluster::secure,

) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-client':
    ensure  => present,
    notify  => Class['profile::mapr::configure_c'],
  }

}

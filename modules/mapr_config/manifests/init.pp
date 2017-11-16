# Class: mapr_config
#
# This module just defines configuration variables
#

class mapr_config (
  $cluster_name   = $mapr_config::cluster_name,
  $cldb_node_list = $mapr_config::cldb_node_list,
  $zk_node_list   = $mapr_config::zk_node_list,
  $historyserver  = $mapr_config::historyserver,
  $secure         = $mapr_config::secure,
  $kerberos       = $mapr_config::kerberos,
  $disk_list      = $mapr_config::disk_list,
) {

}
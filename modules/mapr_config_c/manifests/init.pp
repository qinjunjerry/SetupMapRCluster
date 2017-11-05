# Class: mapr_config_c
#
# This module runs configure.sh -c for a client node
#

class mapr_config_c (
  $cluster_name   = $mapr_config::cluster_name,
  $cldb_node_list = $mapr_config::cldb_node_list,
  $zk_node_list   = $mapr_config::zk_node_list,
  $secure         = $mapr_config::secure,
) {

  require mapr_sasl
  require mapr_kerberos

  # run configure_mapr.sh -c
  exec { 'Run configure.sh -c':
    command     => join(['/usr/bin/sudo /opt/mapr/server/configure.sh',
                         ' ', '-N', ' ', $cluster_name,
                         ' ', '-Z', ' ', $zk_node_list,
                         ' ', '-C', ' ', $cldb_node_list,
                         ' ', $secure,
                         ' ', '-c'
                       ]),
    refreshonly => true,
  }

}
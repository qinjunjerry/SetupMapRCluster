# Class: profile::mapr::configure_c
#
# This module runs configure.sh -c for a client node
#

class profile::mapr::configure_c (
) {

  require profile::mapr::sasl
  require profile::mapr::kerberos

  include profile::mapr::cluster

  # run configure_mapr.sh -c
  exec { 'Run configure.sh -c':
    command     => join(['/usr/bin/sudo /opt/mapr/server/configure.sh',
                         ' ', '-N', ' ', $profile::mapr::cluster::cluster_name,
                         ' ', '-Z', ' ', $profile::mapr::cluster::zk_node_list,
                         ' ', '-C', ' ', $profile::mapr::cluster::cldb_node_list,
                         ' ', $profile::mapr::cluster::secure,
                         ' ', '-c'
                       ]),
    refreshonly => true,
  }

}
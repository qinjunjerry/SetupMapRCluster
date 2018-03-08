# Class: profile::mapr::configure_c
#
# This module runs configure.sh -c for a client node
#

class profile::mapr::configure_c (
) {
  include profile::mapr::client

  $secure_opt = $profile::mapr::client::secure ? {
    true    => "-secure",
    default => ""
  }
  # run configure_mapr.sh -c
  exec { 'Run configure.sh -c':
    command     => join(['/usr/bin/sudo /opt/mapr/server/configure.sh',
                         ' ', '-N', ' ', $profile::mapr::client::cluster_name,
                         ' ', '-Z', ' ', $profile::mapr::client::zk_node_list,
                         ' ', '-C', ' ', $profile::mapr::client::cldb_node_list,
                         ' ', $secure_opt,
                         ' ', '-c'
                       ]),
    refreshonly => true,
  }

}

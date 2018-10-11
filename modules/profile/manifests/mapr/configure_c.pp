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

  # append domain name to each hostname if not already done
  $zk_node_list = join ( 
      split($profile::mapr::cluster::zk_node_list,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  $cldb_node_list = join ( 
      split($profile::mapr::cluster::cldb_node_list,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')


  # run configure_mapr.sh -c
  exec { 'Run configure.sh -c':
    command     => join(['/usr/bin/sudo /opt/mapr/server/configure.sh',
                         ' ', '-N', ' ', $profile::mapr::client::cluster_name,
                         ' ', '-Z', ' ', $zk_node_list,
                         ' ', '-C', ' ', $cldb_node_list,
                         ' ', $secure_opt,
                         ' ', '-c'
                       ]),
    refreshonly => true,
  }

}

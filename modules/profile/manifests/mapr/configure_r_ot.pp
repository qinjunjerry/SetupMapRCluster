# Class: profile::mapr::configure_r_ot
#
# This module runs configure.sh -R -OT
#

class profile::mapr::configure_r_ot (
) {

  include profile::mapr::cluster


  # append domain name to each hostname if not already done
  $opentsdb_node = join ( 
      split($profile::mapr::cluster::opentsdb_node,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  $elastic_node = join ( 
      split($profile::mapr::cluster::elastic_node,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  exec { 'Run configure.sh -R -OT':
    command     => "/opt/mapr/server/configure.sh -R -ES $elastic_node -OT $opentsdb_node",
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['profile::mapr::warden_restart2']
  }

}

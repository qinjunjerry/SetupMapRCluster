# Class: profile::mapr::configure_r_ot
#
# This module runs configure.sh -R -OT
#

class profile::mapr::configure_r_ot (
) {

  include profile::mapr::cluster

  exec { 'Run configure.sh -R -OT':
    command     => "/opt/mapr/server/configure.sh -R -ES $profile::mapr::cluster::elastic_node -OT $profile::mapr::cluster::opentsdb_node",
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['profile::mapr::warden_restart2']
  }

}

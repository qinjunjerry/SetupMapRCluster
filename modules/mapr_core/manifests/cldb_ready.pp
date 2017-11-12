# Class: mapr_core::cldb_ready
#
# This module ensures MapR cldb is ready
#

class mapr_core::cldb_ready (
  $cluster_name = $mapr_config::cluster_name,
) {

  require mapr_config

  exec { 'kinit mapr':
    command   => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr/$cluster_name",
    logoutput => on_failure,
    require   => File['/opt/mapr/conf/mapr.keytab'],
  }
  ->
  exec { "ensure cldb ready":
    command   => "/MapRSetup/scripts/ensure_cldb_ready.sh",
    logoutput => on_failure,
  }
}
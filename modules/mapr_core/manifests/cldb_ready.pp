# Class: mapr_core::cldb_ready
#
# This module ensures MapR cldb is ready
#

class mapr_core::cldb_ready (
) {

  require mapr_config

  exec { 'kinit mapr':
    command   => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr",
    logoutput => on_failure,
    require   => File['/opt/mapr/conf/mapr.keytab'],
  }
  ->
  exec { "ensure cldb ready":
    command   => "/MapRSetup/scrips/ensure_cldb_ready.sh",
    logoutput => on_failure,
  }
}
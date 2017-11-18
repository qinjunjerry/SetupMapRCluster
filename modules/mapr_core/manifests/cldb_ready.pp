# Class: mapr_core::cldb_ready
#
# This module ensures MapR cldb is ready
#

class mapr_core::cldb_ready (
  $cluster_name = $mapr_config::cluster_name,
) {

  require mapr_config::configure

  if $mapr_config::kerberos == true {
    exec { 'kinit mapr':
      command     => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr/$cluster_name",
      logoutput   => on_failure,
      require     => File['/opt/mapr/conf/mapr.keytab'],
      unless      => '/usr/bin/maprcli node cldbmaster',
      before      => Exec['ensure cldb ready'],
    }
  }

  exec { "ensure cldb ready":
    command     => "$::base_dir/scripts/ensure_cldb_ready.sh",
    logoutput   => on_failure,
    unless      => '/usr/bin/maprcli node cldbmaster',
  }
}
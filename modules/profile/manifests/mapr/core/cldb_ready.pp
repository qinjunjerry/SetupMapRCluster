# Class: profile::mapr::core::cldb_ready
#
# This module ensures MapR cldb is ready
#

class profile::mapr::core::cldb_ready (
) {

  require profile::mapr::configure

  include profile::mapr::cluster

  if $profile::mapr::cluster::kerberos == true {
    exec { 'kinit mapr':
      command     => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr/$profile::mapr::cluster::cluster_name",
      logoutput   => on_failure,
      require     => File['/opt/mapr/conf/mapr.keytab'],
      unless      => '/usr/bin/maprcli node cldbmaster',
      before      => Exec['ensure cldb ready'],
    }
  }

  exec { "ensure cldb ready":
    command     => "$::base_dir/utils/ensure_cldb_ready.sh",
    logoutput   => on_failure,
    unless      => '/usr/bin/maprcli node cldbmaster',
  }
}

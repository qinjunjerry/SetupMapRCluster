# Class: profile::mapr::core::cldb_ready
#
# This module ensures MapR cldb is ready
#

class profile::mapr::core::cldb_ready (
) {

  require profile::mapr::configure

  include profile::mapr::cluster

  if $profile::mapr::cluster::kerberos == true {
    # 'remove maprticket' is necessary in case there was an outdated ticket in which case 
    # 'maprcli node cldbmaster' does not generate a new one
    exec { 'kinit mapr && rm maprticket':
      command     => "/bin/kinit -kt /opt/mapr/conf/mapr.keytab mapr/$profile::mapr::cluster::cluster_name && rm -f /tmp/maprticket_`id -u`",
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

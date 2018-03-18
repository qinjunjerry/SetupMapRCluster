# Class: profile::mapr::core::nodemanager_ready
#
# This module ensures MapR nodemanager is ready
#

class profile::mapr::core::nodemanager_ready (
) {
  require profile::mapr::core::cldb_ready

  exec { "ensure nodemanager ready":
    command     => "$::base_dir/utils/ensure_nodemanager_ready.sh",
    logoutput   => on_failure,
    unless      => '/usr/bin/hadoop fs -ls /var/mapr/local/$(hostname -f)',
  }

}

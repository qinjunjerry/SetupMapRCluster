# Class: profile::mapr::warden_restart2
#
# This module restarts mapr-warden after opentsdb/grafana/collectd installed
#

class profile::mapr::warden_restart2 (
) {

  exec { 'restart mapr-warden 2nd':
    command     => '/usr/bin/systemctl restart mapr-warden',
    logoutput   => on_failure,
    refreshonly => true,
   }

}

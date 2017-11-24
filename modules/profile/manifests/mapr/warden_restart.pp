# Class: profile::mapr::warden_restart
#
# This module restarts mapr-warden
#

class profile::mapr::warden_restart (
) {

  exec { 'restart mapr-warden':
    command     => '/usr/bin/systemctl restart mapr-warden',
    logoutput   => on_failure,
    refreshonly => true,
  }

}

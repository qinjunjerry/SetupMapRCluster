# Class: profile::mapr::configure_r
#
# This module runs configure.sh -R
#

class profile::mapr::configure_r (
) {

  exec { 'Run configure.sh -R':
    command     => '/opt/mapr/server/configure.sh -R',
    logoutput   => on_failure,
    refreshonly => true,
  }

}
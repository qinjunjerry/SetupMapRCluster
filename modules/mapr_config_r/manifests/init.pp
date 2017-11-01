# Class: mapr_config_r
#
# This module runs configure.sh -R
#

class mapr_config_r (
) {

  exec { 'Run configure.sh -R':
    command     => '/opt/mapr/server/configure.sh -R',
    logoutput   => on_failure,
    refreshonly => true,
  } 

}
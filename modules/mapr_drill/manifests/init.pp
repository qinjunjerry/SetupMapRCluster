# Class: mapr_drill
#
# This module installs/configures MapR drill
#

class mapr_drill (
) {

  require mapr_pre
  require mapr_repo
  require mapr_user
  require mapr_config::configure


  $drill_config = '/opt/mapr/drill/drill-1.10.0/bin/drill-config.sh'

  package { 'mapr-drill':
    ensure  => present,
    notify  => Class['mapr_config_r'],
  }

  file_line { 'fix bug: drill log dir':
    ensure             => 'present',
    path               => $drill_config,
    line               => '    DRILL_LOG_DIR=$DRILL_HOME/logs',
    match              => '^\s+DRILL_LOG_DIR\=$DRILL_HOME/log',
    append_on_no_match => false,
    require            => Package['mapr-drill'],
  }

  file_line { 'fix bug: java version detection':
    ensure             => 'present',
    path               => $drill_config,
    line               => '"$JAVA" -version 2>&1 | grep "version" | egrep -e "1\.4|1\.5|1\.6" > /dev/null',
    match              => '^"$JAVA" -version 2>&1 | grep "version" | egrep -e "1.4|1.5|1.6" > /dev/null',
    append_on_no_match => false,
    require            => Package['mapr-drill'],
  }

}
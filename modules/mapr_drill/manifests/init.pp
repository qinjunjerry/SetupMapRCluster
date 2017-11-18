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

  include mapr_config


  $drill_home   = '/opt/mapr/drill/drill-1.10.0'
  $drill_config = "$drill_home/bin/drill-config.sh"

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

  $cluster_id = regsubst($mapr_config::cluster_name, '\.', '_', 'G')
  $zk_connect = join ( suffix( split($mapr_config::zk_node_list,','), ":5181" ), ',')

  file { 'drill-override.conf':
    ensure  => file,
    path    => "$drill_home/conf/drill-override.conf",
    content => epp('mapr_drill/drill-override.conf.epp'),
    require => Package['mapr-drill'],
  }

  # Bug fix: java.lang.UnsatisfiedLinkError: no jpam in java.library.path
  file { "$drill_home/lib":
    ensure  => directory,
    owner   => 'mapr',
    group   => 'root',
    mode    => '0755',
  }
  ->
  file { "$drill_home/lib/libjpam.so":
    ensure => link,
    owner  => 'mapr',
    group  => 'root',
    mode   => '0644',
    target => '/opt/mapr/lib/libjpam.so',
  }
  ->
  file_line { 'DRILL_JAVA_LIB_PATH in drill-env.sh':
    ensure             => 'present',
    path               => "$drill_home/conf/drill-env.sh",
    #line               => "export DRILLBIT_JAVA_OPTS=\"-Djava.library.path=$drill_home/lib/\"",
    #match              => '^export\ DRILLBIT_JAVA_OPTS\=',
    line               => "export DRILL_JAVA_LIB_PATH=\"$drill_home/lib\"",
    match              => '^export\ DRILL_JAVA_LIB_PATH\=',
    append_on_no_match => true,
    require            => Package['mapr-drill'],
  }

}
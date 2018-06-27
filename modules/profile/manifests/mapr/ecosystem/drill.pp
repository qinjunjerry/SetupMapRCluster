# Class: profile::mapr::ecosystem::drill
#
# This module installs/configures MapR drill
#

class profile::mapr::ecosystem::drill (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::configure

  include profile::mapr::cluster


  $version = fact('mapr-drill:version')
  $drill_home   = "/opt/mapr/drill/drill-$version"
  $drill_config = "$drill_home/bin/drill-config.sh"

  package { 'mapr-drill':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
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

  $cluster_id = regsubst($profile::mapr::cluster::cluster_name, '\.', '_', 'G')
  $zk_connect = join ( suffix( split($profile::mapr::cluster::zk_node_list,','), ":5181" ), ',')


  file { '/etc/pam.d/drill':
    ensure  => file,
    source  => 'puppet:///modules/profile/mapr/ecosystem/drill/drill',
  }
  ->
##file { 'drill-override.conf':
##  ensure  => file,
##  path    => "$drill_home/conf/drill-override.conf",
##  content => epp('profile/mapr/ecosystem/drill/drill-override.conf.epp'),
##  require => Package['mapr-drill'],
##}
  hocon_setting {
    default:
        ensure  => present,
        path    => "$drill_home/conf/drill-override.conf";
    'drill.exec.cluster-id':
        value   => "${cluster_id}-drillbits";
    'drill.exec.zk.connect':
        value   => $zk_connect;
  }

  if $profile::mapr::cluster::secure == true {
    hocon_setting {
      default:
          ensure  => present,
          require => Hocon_setting['drill.exec.cluster-id'],
          path    => "$drill_home/conf/drill-override.conf";
      'drill.exec.impersonation.enabled':
          value   => true;
      'drill.exec.impersonation.max_chained_user_hops':
          value   => 3;
      'drill.exec.security.auth.mechanisms':
          value   => ['MAPRSASL', 'PLAIN'];
      'drill.exec.security.user.auth.enabled':
          value   => true;
      'drill.exec.security.user.auth.packages':
          value   => 'org.apache.drill.exec.rpc.user.security',
          type    => 'array_element';
      'drill.exec.security.user.auth.impl':
          value   => 'pam';
      'drill.exec.security.user.auth.pam_profiles':
          value   => ['drill'],
          type    => 'array';
    }

    if $profile::mapr::cluster::kerberos == true {
      hocon_setting {
        default:
            ensure  => present,
            require => Hocon_setting['drill.exec.cluster-id'],
            path    => "$drill_home/conf/drill-override.conf";
        'drill.exec.http.ssl_enabled':
            value   => true;
        'drill.exec.javax.net.ssl.keyStore':
            value   => '/opt/mapr/conf/ssl_keystore';
        'drill.exec.javax.net.ssl.keyStorePassword':
            value   => 'mapr123';
        'drill.exec.javax.net.ssl.trustStore':
            value   => '/opt/mapr/conf/ssl_truststore';
        'drill.exec.javax.net.ssl.trustStorePassword':
            value   => 'mapr123';
      }
    }
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

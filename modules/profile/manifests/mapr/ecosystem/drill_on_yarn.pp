# Class: profile::mapr::ecosystem::drill_on_yarn
#
# This module installs/configures MapR drill_on_yarn
#

class profile::mapr::ecosystem::drill_on_yarn (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user
  require profile::mapr::configure

  include profile::mapr::cluster


  $version = fact('mapr-drill:version')
  $drill_base   = "/opt/mapr/drill"
  $drill_home   = "$drill_base/drill-$version"
  $drill_config = "$drill_home/bin/drill-config.sh"
  $drill_site   = "$drill_base/site"

  package { 'mapr-drill-yarn':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r'],
  }
  
  # Make sure the user starts drill-on-yarn (mapr in this case):
  # - can write into /opt/mapr/drill to create drillbit cluster pid file: /opt/mapr/drill/drill-<drillbits_cluster>.appid
  # - in shadow group (such that the started drill allow other users to login)
  -> 
  file { "/opt/mapr/drill":
    ensure  => directory,
    owner   => 'mapr',
    group   => 'mapr',
    mode    => '0755',
  }
  -> 
  file { "$drill_site":
    ensure  => directory,
    owner   => 'mapr',
    group   => 'mapr',
    mode    => '0755',
  }
  
  exec { "create $drill_site/drill-override.conf":
    command   => "/usr/bin/cp $drill_home/conf/drill-override.conf $drill_site",
    creates   => "$drill_site/drill-override.conf",
    logoutput => on_failure,
    require   => File["$drill_site"],
  } 
  -> 
  file { "$drill_site/drill-override.conf":
    owner   => 'mapr',
    group   => 'mapr',
  }

  exec { "create $drill_site/drill-on-yarn.conf":
    command   => "/usr/bin/cp $drill_home/conf/drill-on-yarn.conf $drill_site",
    creates   => "$drill_site/drill-on-yarn.conf",
    logoutput => on_failure,
    require   => File["$drill_site"],
  } 
  -> 
  file { "$drill_site/drill-on-yarn.conf":
    owner   => 'mapr',
    group   => 'mapr',
  }

  exec { "create $drill_site/drill-env.sh":
    command   => "/usr/bin/cp $drill_home/conf/drill-env.sh $drill_site",
    creates   => "$drill_site/drill-env.sh",
    logoutput => on_failure,
    require   => File["$drill_site"],
  } 
  -> 
  file { "$drill_site/drill-env.sh":
    owner   => 'mapr',
    group   => 'mapr',
  }

  exec { "create $drill_site/distrib-env.sh":
    command   => "/usr/bin/cp $drill_home/conf/distrib-env.sh $drill_site",
    creates   => "$drill_site/distrib-env.sh",
    logoutput => on_failure,
    require   => File["$drill_site"],
  } 
  -> 
  file { "$drill_site/distrib-env.sh":
    owner   => 'mapr',
    group   => 'mapr',
  }

  file_line { 'fix bug: drill log dir':
    ensure             => 'present',
    path               => $drill_config,
    line               => '    DRILL_LOG_DIR=$DRILL_HOME/logs',
    match              => '^\s+DRILL_LOG_DIR\=$DRILL_HOME/log',
    append_on_no_match => false,
    require            => Package['mapr-drill-yarn'],
  }

  if versioncmp($version, '1.14.0') < 0 {
    file_line { 'fix bug: java version detection':
      ensure             => 'present',
      path               => $drill_config,
      line               => '"$JAVA" -version 2>&1 | grep "version" | egrep -e "1\.4|1\.5|1\.6" > /dev/null',
      match              => '^"$JAVA" -version 2>&1 | grep "version" | egrep -e "1.4|1.5|1.6" > /dev/null',
      append_on_no_match => false,
      require            => Package['mapr-drill-yarn'],
    }
  }

  $cluster_id = regsubst($profile::mapr::cluster::cluster_name, '\.', '_', 'G')
  # append domain name to each hostname if not already done
  $zk_connect = join ( suffix( 
        split($profile::mapr::cluster::zk_node_list,',').map |$item| { 
          if $item =~ /.+\..+/ {$item} else { "${item}.${profile::mapr::prereq::domain}" 
        } 
      }, ":5181" ), ',')


  file { '/etc/pam.d/drill':
    ensure  => file,
    source  => 'puppet:///modules/profile/mapr/ecosystem/drill/drill',
  }
  
  hocon_setting {
    default:
        ensure  => present,
        path    => "$drill_site/drill-override.conf";
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
          path    => "$drill_site/drill-override.conf";
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
            path    => "$drill_site/drill-override.conf";
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
  # To be done on all nodes
  file { "$drill_base/lib":
    ensure  => directory,
    owner   => 'mapr',
    group   => 'root',
    mode    => '0755',
  }
  ->
  file { "$drill_base/lib/libjpam.so":
    ensure => link,
    owner  => 'mapr',
    group  => 'root',
    mode   => '0644',
    target => '/opt/mapr/lib/libjpam.so',
  }
  ->
  file_line { 'DRILL_JAVA_LIB_PATH in drill-env.sh':
    ensure             => 'present',
    path               => "$drill_site/drill-env.sh",
    #line               => "export DRILLBIT_JAVA_OPTS=\"-Djava.library.path=$drill_base/lib/\"",
    #match              => '^export\ DRILLBIT_JAVA_OPTS\=',
    line               => "export DRILL_JAVA_LIB_PATH=\"$drill_base/lib\"",
    match              => '^export\ DRILL_JAVA_LIB_PATH\=',
    append_on_no_match => true,
    require            => Package['mapr-drill-yarn'],
  }


  # to be done on all node
  file { '/etc/tmpfiles.d/exclude-nm-local-dir.conf':
  	ensure => file,
  	content => "x /tmp/hadoop-mapr/nm-local-dir/*"
  }



}


# yum install mapr-drill-yarn
# 
# make sure mapr can write into: /opt/mapr/drill to create drillbit cluster pid file:
# /opt/mapr/drill/drill-coco_cluster-drillbits.appid
# /opt/mapr/drill/site
# 
# export DRILL_HOME=/opt/mapr/drill/drill-1.13.0
# export DRILL_SITE=/opt/mapr/drill/site
# mkdir -p $DRILL_SITE
# 
# copy are mapr user:
# cp $DRILL_HOME/conf/drill-override.conf $DRILL_SITE
# cp $DRILL_HOME/conf/drill-env.sh $DRILL_SITE
# cp $DRILL_HOME/conf/drill-on-yarn.conf $DRILL_SITE
# cp $DRILL_HOME/conf/distrib-env.sh $DRILL_SITE
# 
# make sure zookeeper connect is set correct in drill-override.conf
# 
# drill-on-yarn.conf: keep the default memory/CPU/disk settings: 3 + 3 + 1 + 1 = 8GB
# 
# leave yarn.scheduler.maximum-allocation-mb also at its default size 8GB
# 
# create this file to prevent drill bit tmp file from being cleaned up
# cat /etc/tmpfiles.d/exclude-nm-local-dir.conf
# x /tmp/hadoop-mapr/nm-local-dir/*
# 
# if need secured drill-on-yarn, other settings are also needed:
#  drill-override.conf
#  /etc/pam.d/drill
#  /opt/mapr/jpam/lib
#  drill-env.sh
# Also make sure the user who starts dill-on-yarn are also in shadow group.
# 
# To start as mapr user: 
# - make sure a valid mapr ticket exists
# - DRILL/bin/drill-on-yarn.sh --site /opt/mapr/drill/site start
# To start as a different user (e.g., with another user's ticket)
# make sure: 
# chmod 777 /mapr/coco.cluster/user/drill
# rm /mapr/coco.cluster/user/drill/*
# rm -fr /tmp/drill
# create user's home in MapR FS
# chmod a+x drill-on-yarn.sh
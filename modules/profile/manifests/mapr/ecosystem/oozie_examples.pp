# Class: profile::mapr::ecosystem::oozie
#
# This module installs/configures MapR oozie
#

class profile::mapr::ecosystem::oozie_examples (
) {

  require profile::mapr::ecosystem::oozie
  require profile::mapr::core::cldb_ready

  $version = fact('mapr-oozie:version')

  exec { 'untar oozie-examples.tar.gz':
    command   => "/usr/bin/tar -zxvf /opt/mapr/oozie/oozie-$version/oozie-examples.tar.gz -C /opt/mapr/oozie/oozie-$version",
    logoutput => on_failure,
    unless    => "/usr/bin/test -d /opt/mapr/oozie/oozie-$version/examples",
  }
  ->
  exec { 'upload examples/':
    command   => "/usr/bin/hadoop fs -put /opt/mapr/oozie/oozie-$version/examples maprfs:///user/mapr/examples",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /user/mapr/examples",
  }
  ->
  exec { 'upload input-data/':
    command   => "/usr/bin/hadoop fs -put /opt/mapr/oozie/oozie-$version/examples/input-data maprfs:///user/mapr/input-data",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /user/mapr/input-data",
  }
  ->
  exec { 'chmod 777 examples':
    command   => "/usr/bin/hadoop fs -chmod -R 777 /user/mapr/examples",
    logoutput => on_failure,
    unless    => "/usr/bin/hadoop fs -ls /user/mapr/ | grep -E drwxrwxrwx.*/user/mapr/examples",
    before    => Class['profile::mapr::warden_restart'],
  }
}

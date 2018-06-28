# Class: profile::mapr::ecosystem::opentsdb
#
# This module installs/configures MapR Monitoring component: opentsdb
#

class profile::mapr::ecosystem::opentsdb (
) {

  require profile::mapr::configure_r

  $version = fact('mapr-opentsdb:version')

  package { 'mapr-opentsdb':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r_ot'],
  }

  ->
  cron { 'opentsdb purge data':
    command => "/opt/mapr/opentsdb/opentsdb-$version/bin/tsdb_cluster_mgmt.sh -purgeData >> /opt/mapr/opentsdb/opentsdb-$version/var/log/opentsdb/ot_purgeData.log 2>&1",
    user    => 'mapr',
    hour    => 1,
    minute  => 15,
  }

}

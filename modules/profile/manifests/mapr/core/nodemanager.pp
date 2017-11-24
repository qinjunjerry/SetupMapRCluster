# Class: profile::mapr::core::nodemanager
#
# This module installs/configures MapR nodemanager
#

class profile::mapr::core::nodemanager (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  $cfgfile = '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml'

  package { 'mapr-nodemanager':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
    before  => Class['profile::mapr::core::rm_nm_common'],
  }

}

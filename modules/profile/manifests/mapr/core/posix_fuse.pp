# Class: profile::mapr::core::posix_fuse
#
# This module installs/configures MapR posix client basics
#

class profile::mapr::core::posix_fuse (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-posix-client-basic':
    ensure  => present,
    notify  => Class['profile::mapr::configure_c'],
    require => Class['profile::mapr::client'],
  }
  ->
  file { '/mapr' :
  	ensure => directory,
  }
  ->
  service { 'mapr-posix-client-basic':
  	ensure => running,
  }
}

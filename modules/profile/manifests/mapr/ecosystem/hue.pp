# Class: profile::mapr::ecosystem::hue
#
# This module installs/configures MapR hue
#

class profile::mapr::ecosystem::hue (
) {

  require profile::mapr::configure

  package { 'mapr-hue':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

  $version = fact('mapr-hue:version')
  $cfgfile = "/opt/mapr/hue/hue-$version/desktop/conf/hue.ini"

  file_line {'resourcemanager_host in hue.ini':
  	ensure   => 'present',
  	line     => '      resourcemanager_host=maprfs:///',
  	path     => $cfgfile,
  	after    => '## resourcemanager_host=localhost',
  	match    => '^\s*resourcemanager_host\=',
  	require  => Package['mapr-hue'],
  }

  file_line {'webhdfs_url in hue.ini':
  	ensure   => 'present',
  	line     => '      webhdfs_url=http://node69:14000/webhdfs/v1',
  	path     => $cfgfile,
  	after    => '# Default port is 14000 for HttpFs.',
  	match    => '^\s*webhdfs_url\=',
  	require  => Package['mapr-hue'],
  }


}

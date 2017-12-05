# Class: profile::mapr::ecosystem::hue
#
# This module installs/configures MapR hue
#

class profile::mapr::ecosystem::hue (
) {

  include profile::mapr::cluster
  require profile::mapr::configure

  package { 'mapr-hue':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

  $version = fact('mapr-hue:version')
  $cfgfile = "/opt/mapr/hue/hue-$version/desktop/conf/hue.ini"

  file_line {'resourcemanager_host in hue.ini':
  	ensure   => 'present',
  	path     => $cfgfile,
    line     => '      resourcemanager_host=maprfs:///',
  	after    => '## resourcemanager_host=localhost',
  	match    => '^\s*resourcemanager_host\=',
  	require  => Package['mapr-hue'],
  }

  $domain=$profile::mapr::prereq::domain
  file_line {'resourcemanager_api_url in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => "      resourcemanager_api_url=https://node69.$domain:8090",
    after    => '      # URL of the ResourceManager API',
    match    => '^\s*resourcemanager_api_url\=',
    require  => Package['mapr-hue'],
  }

  file_line {'webhdfs_url in hue.ini':
  	ensure   => 'present',
  	path     => $cfgfile,
    line     => '      webhdfs_url=http://node69:14000/webhdfs/v1',
  	after    => '# Default port is 14000 for HttpFs.',
  	match    => '^\s*webhdfs_url\=',
  	require  => Package['mapr-hue'],
  }

  $hostname = fact('networking.hostname')
  exec { '/tmp/hue_krb5_ccache':
    command  => "/bin/kinit -k -t /opt/mapr/conf/mapr.keytab -c /tmp/hue_krb5_ccache mapr/$hostname",
    creates  => '/tmp/hue_krb5_ccache',
    require  => Package['mapr-hue'],
  }

  file_line {'hue_keytab in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => '    hue_keytab=/opt/mapr/conf/mapr.keytab',
    after    => "# Path to Hue's Kerberos keytab file",
    match    => '^\s*hue_keytab\=',
    require  => Package['mapr-hue'],
  }

  file_line {'hue_principal in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => "    hue_principal=mapr/$hostname",
    after    => "# Kerberos principal name for Hue",
    match    => '^\s*hue_principal\=',
    require  => Package['mapr-hue'],
  }

  file_line {'kinit_path in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => '    kinit_path=/bin/kinit',
    after    => '# Path to kini',
    match    => '^\s*kinit_path\=',
    require  => Package['mapr-hue'],
  }

  $oozie_node=$profile::mapr::cluster::oozie_node
  file_line {'oozie_url in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => "  oozie_url=http://$oozie_node:11000/oozie",
    after    => '# users to submit jobs. Empty value disables the config check.',
    match    => '^\s*oozie_url\=',
    require  => Package['mapr-hue'],
  }

}

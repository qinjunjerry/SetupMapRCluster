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

  # This requires that httpfs must run on the Hue node
  # In case of multiple httpfs, httpfs must setup as active-active instead of active-standby
  # In a secure MapR 5.x cluster, this still should be 'http' as server.xml in httpfs does not have SSLEnabled="true"
  $hostname = fact('networking.fqdn')
  $protocol = $profile::mapr::cluster::secure ? {
    true    => 'https',
    default => 'http'
  }
  file_line {'webhdfs_url in hue.ini':
  	ensure   => 'present',
  	path     => $cfgfile,
    line     => "      webhdfs_url=${protocol}://${hostname}:14000/webhdfs/v1",
  	after    => '# Default port is 14000 for HttpFs.',
  	match    => '^\s*webhdfs_url\=',
  	require  => Package['mapr-hue'],
  }

  if $profile::mapr::cluster::kerberos == true {
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
  }

  # append domain name to hostname if not already done
  $oozie_node = $profile::mapr::cluster::oozie_node =~ /.+\..+/ ? {
    true    => $profile::mapr::cluster::oozie_node,
    default => "${profile::mapr::cluster::oozie_node}.${profile::mapr::prereq::domain}"
  }

  file_line {'oozie_url in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => "  oozie_url=http://$oozie_node:11000/oozie",
    after    => '# users to submit jobs. Empty value disables the config check.',
    match    => '^\s*oozie_url\=',
    require  => Package['mapr-hue'],
  }

  # append domain name to hostname if not already done
  $hive_server2_node = $profile::mapr::cluster::hive_server2_node =~ /.+\..+/ ? {
    true    => $profile::mapr::cluster::hive_server2_node,
    default => "${profile::mapr::cluster::hive_server2_node}.${profile::mapr::prereq::domain}"
  }

  file_line {'hive_server_host in hue.ini':
    ensure   => 'present',
    path     => $cfgfile,
    line     => "  hive_server_host=${hive_server2_node}",
    after    => '# If Kerberos security is enabled, use fully-qualified domain name',
    match    => '^\s*hive_server_host\=',
    require  => Package['mapr-hue'],
  }


}

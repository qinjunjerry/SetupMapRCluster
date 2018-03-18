# Class: profile::mapr::ecosystem::nm_local_dirs
#
# This module configures nodemanager local dirs to MapR FS
#

class profile::mapr::core::nm_local_dirs (
) {

  require profile::mapr::core::nodemanager_ready
  require profile::mapr::core::nfs

  include profile::mapr::cluster

  exec { 'check license':
    command   => '/usr/bin/maprcli license apps | grep NFS',
    logoutput => on_failure,
  }
  ->
  exec { 'create nodemanger local volume':
    command   => '/opt/mapr/bin/maprcli volume create -name mapr.$(hostname -f).local.nm-local-dir -path /var/mapr/local/$(hostname -f)/nm-local-dir -replication 1 -localvolumehost $(hostname -f)',
    logoutput => on_failure,
    unless    => '/opt/mapr/bin/maprcli volume list -columns volumename,mountdir | grep mapr.$(hostname -f).local.nm-local-dir',
    before    => Class['profile::mapr::warden_restart'],
  }
  ->
  file { '/mapr':
    ensure   => directory,
  }
  ->
  exec { 'mount maprfs':
    command   => '/usr/bin/mount -o hard,nolock localhost:/mapr /mapr',
    logoutput => on_failure,
    unless    => '/usr/bin/df -h | grep localhost:/mapr',
    before    => Class['profile::mapr::warden_restart'],
  }
  ->
  profile::hadoop::xmlconf_property {
    default:
      file   => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/yarn-site.xml',
      notify => Class['profile::mapr::warden_restart'];

    "yarn.nodemanager.local-dirs" : value =>"/mapr/$profile::mapr::cluster::cluster_name/var/mapr/local/\${mapr.host}/nm-local-dir";

  }

}

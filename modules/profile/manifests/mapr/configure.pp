# Class: profile::mapr::configure
#
# This module runs configure.sh and start mapr-zookeeper and mapr-warden
#

class profile::mapr::configure (
) {
  include profile::mapr::cluster

  if $profile::mapr::cluster::secure == true {
    require profile::mapr::sasl

    if $profile::mapr::cluster::kerberos == true {
      require profile::mapr::kerberos
    }
  }

  $secure_opt = $profile::mapr::cluster::secure ? {
    true    => "-secure",
    default => ""
  }

  $kerberos_opt = $profile::mapr::cluster::kerberos ? {
    true    => "-kerberosEnable -P mapr/$profile::mapr::cluster::cluster_name",
    default => ""
  }

  $disk_file = '/tmp/disks.txt'

  exec { 'configure.sh':
    command     => join(['/opt/mapr/server/configure.sh',
                         ' ', '-N',  ' ', $profile::mapr::cluster::cluster_name,
                         ' ', '-Z',  ' ', $profile::mapr::cluster::zk_node_list,
                         ' ', '-C',  ' ', $profile::mapr::cluster::cldb_node_list,
                         ' ', '-HS', ' ', $profile::mapr::cluster::historyserver,
                         ' ', $secure_opt,
                         ' ', $kerberos_opt,
                         ' ', '-nocerts',
                         ' ', '-no-autostart',
                         ' ', '-f',
                       ]),
    logoutput   => on_failure,
    refreshonly => true,
  }
  ~>
  exec { 'create disks.txt and run disksetup':
    command   => "echo $profile::mapr::cluster::disk_list > $disk_file && /opt/mapr/server/disksetup -F $disk_file",
    path      => '/usr/bin:/usr/sbin:/bin',
    logoutput => on_failure,
    creates   => '/opt/mapr/conf/disktab',
  }
  ~>
  service { 'mapr-zookeeper':
    enable      => true,
    ensure      => running,
  }
  ~>
  service { 'mapr-warden':
    enable      => true,
    ensure      => running,
  }

}

# Class: mapr_config
#
# This module generates configure_mapr.sh and runs it
#

class mapr_config (
  $cluster_name   = $mapr_config::cluster_name,
  $cldb_node_list = $mapr_config::cldb_node_list,
  $zk_node_list   = $mapr_config::zk_node_list,
  $historyserver  = $mapr_config::historyserver,
  $secure         = $mapr_config::secure,
  $kerberos       = $mapr_config::kerberos,
  $disk_list      = $mapr_config::disk_list,
  $kdc            = $mapr_config::kdc,
) {

  require mapr_config::sasl
  require mapr_config::kerberos

  $secure_opt = $secure ? {
    true    => "-secure",
    default => ""
  }

  $kerberos_opt = $kerberos ? {
    true    => "-kerberosEnable -P mapr/$cluster_name",
    default => ""
  }

  $disk_file = '/tmp/disks.txt'

  exec { 'run configure.sh':
    command     => join(['/opt/mapr/server/configure.sh',
                         ' ', '-N', ' ', $cluster_name,
                         ' ', '-Z', ' ', $zk_node_list,
                         ' ', '-C', ' ', $cldb_node_list,
                         ' ', '-HS', ' ', $historyserver,
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
  exec { 'create disks.txt':
    command   => "echo $disk_list > $disk_file && /opt/mapr/server/disksetup -F $disk_file",
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
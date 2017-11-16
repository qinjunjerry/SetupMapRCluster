# Class: mapr_config::configure
#
# This module runs configure.sh and start mapr-zookeeper and mapr-warden
#

class mapr_config::configure (
) {
  include mapr_config

  if $mapr_config::secure == true {
    require mapr_config::sasl

    if $mapr_config::kerberos == true {
      require mapr_config::kerberos
    }
  }

  $secure_opt = $mapr_config::secure ? {
    true    => "-secure",
    default => ""
  }

  $kerberos_opt = $mapr_config::kerberos ? {
    true    => "-kerberosEnable -P mapr/$mapr_config::cluster_name",
    default => ""
  }

  $disk_file = '/tmp/disks.txt'

  exec { 'run configure.sh':
    command     => join(['/opt/mapr/server/configure.sh',
                         ' ', '-N',  ' ', $mapr_config::cluster_name,
                         ' ', '-Z',  ' ', $mapr_config::zk_node_list,
                         ' ', '-C',  ' ', $mapr_config::cldb_node_list,
                         ' ', '-HS', ' ', $mapr_config::historyserver,
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
    command   => "echo $mapr_config::disk_list > $disk_file && /opt/mapr/server/disksetup -F $disk_file",
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
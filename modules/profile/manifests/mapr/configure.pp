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

  exec { 'configure.sh':
    command     => join(['/opt/mapr/server/configure.sh',
                         ' ', '-N',  ' ', $profile::mapr::cluster::cluster_name,
                         ' ', '-Z',  ' ', $profile::mapr::cluster::zk_node_list,
                         ' ', '-C',  ' ', $profile::mapr::cluster::cldb_node_list,
                         ' ', '-HS', ' ', $profile::mapr::cluster::historyserver,
                         ' ', '-D',  ' ', $profile::mapr::cluster::disk_list,
                         ' ', '-disk-opts', ' ', 'F',
                         ' ', $secure_opt,
                         ' ', $kerberos_opt,
                         ' ', '-nocerts',
                         # to reduce memory requirement
                         ' ', '--isvm',
#                        ' ', '-no-autostart',
                         ' ', '-f',
                       ]),
    logoutput   => on_failure,
    refreshonly => true,
  }

}

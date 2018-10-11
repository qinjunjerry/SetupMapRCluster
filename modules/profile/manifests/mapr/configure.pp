# Class: profile::mapr::configure
#
# This module runs configure.sh and start mapr-zookeeper and mapr-warden
#

class profile::mapr::configure (
) {
  include profile::mapr::cluster

  $disklist_file = "/tmp/disklist.txt"
  $hostname = fact('networking.hostname')

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

  if $profile::mapr::cluster::secure == true {
    file_line { 'fix configure.sh for secure oozie':
      ensure             => 'present',
      path               => '/opt/mapr/server/configure.sh',
      line               => "      cmd=\"\$oozieDir/bin/oozie-setup.sh -hadoop \"\$hadoopVersion\" \"\${hadoopBase}/hadoop-\${hadoopVersion}\" $secure_opt\"",
      match              => '\s+cmd\="\$oozieDir/bin/oozie-setup.sh -hadoop "\$hadoopVersion" "\${hadoopBase}/hadoop-\${hadoopVersion}""$',
      append_on_no_match => false,
      before             => Exec['Run configure.sh'],
    }
  }

  # append domain name to each hostname if not already done
  $zk_node_list = join ( 
      split($profile::mapr::cluster::zk_node_list,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  $cldb_node_list = join ( 
      split($profile::mapr::cluster::cldb_node_list,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  $historyserver = $profile::mapr::cluster::historyserver =~ /.+\..+/ ? {
    true    => $profile::mapr::cluster::historyserver,
    default => "${profile::mapr::cluster::historyserver}.${profile::mapr::prereq::domain}" 
  }

  exec { 'Run configure.sh':
    command     => join(['/opt/mapr/server/configure.sh',
                         ' ', '-N',  ' ', $profile::mapr::cluster::cluster_name,
                         ' ', '-Z',  ' ', $zk_node_list,
                         ' ', '-C',  ' ', $cldb_node_list,
                         ' ', '-HS', ' ', $historyserver,
#                        ' ', '-D',  ' ', $profile::mapr::cluster::disk_list,
#                        ' ', '-disk-opts', ' ', 'F',
                         ' ', $secure_opt,
                         ' ', $kerberos_opt,
                         ' ', '-nocerts',
                         # to reduce memory requirement
                         ' ', '--isvm',
                         ' ', '-noDB',
                         ' ', '-no-autostart',
                         ' ', '-f',
                       ]),
    logoutput   => on_failure,
  }
  -> 
  file { $disklist_file:
    ensure  => present,
    content => epp('profile/mapr/core/tmp_disklist.epp'),
  }
  ->
  exec { 'disksetup':
    command   => "/opt/mapr/server/disksetup -F $disklist_file",
    path      => '/usr/bin:/usr/sbin:/bin',
    logoutput => on_failure,
    creates   => '/opt/mapr/conf/disktab',
  }

  if $hostname in split($profile::mapr::cluster::zk_node_list, ',') {
    service { 'mapr-zookeeper':
      enable      => true,
      ensure      => running,
      require     => Exec['disksetup'],
    }
    ->
    service { 'mapr-warden':
      enable      => true,
      ensure      => running,
    }
  } else {
    service { 'mapr-warden':
      enable      => true,
      ensure      => running,
      require     => Exec['disksetup'],
    }
  }
}

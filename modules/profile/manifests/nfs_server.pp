class profile::nfs_server (
) {

  $ipaddr = fact('networking.ip')

  package { 'nfs-utils':
    ensure => present,
  }
  ->
  service { 'nfs-server':
    enable => true,
  	ensure => running,
  }
  ->
  # WARN: the '*' here allows any host to mount
  file_line { 'export NFS share':
    ensure => 'present',
    path   => '/etc/exports',
    line   => "/root  *(rw,sync,no_root_squash,no_subtree_check)",
    notify => Exec['Run exportfs'],
  } 

  # run exportfs -a
  exec { 'Run exportfs':
    command     => '/usr/sbin/exportfs -a',
    refreshonly => true,
  }  


}

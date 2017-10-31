# Class: mapr_pre
#
# This module installs/configures the MapR prerequisites
#

class mapr_pre (
  $hosts              = $mapr_pre::hosts,
  $java_version_major = $mapr_pre::java_version_major,
  $java_version_minor = $mapr_pre::java_version_minor,
  $java_url_hash      = $mapr_pre::java_url_hash,
) {

  ### /etc/hosts
  file { '/etc/hosts':
    ensure  => present,
    content => epp('mapr_pre/hosts.epp'),
  }

  ### sysctl.conf
  file_line { 'set-overcommit_memory':
    ensure => present,
    path   => "/etc/sysctl.conf",
    line   => "vm.overcommit_memory=0",
    match  => '^vm.overcommit_memory\=',
  }

  file_line { 'set-net.ipv4.tcp_retries2':
    ensure => present,
    path   => "/etc/sysctl.conf",
    line   => "net.ipv4.tcp_retries2=5",
    match  => '^net.ipv4.tcp_retries2\=',
  }

  ### firewalld
  exec { 'stop-firewalld':
    command   => "/usr/bin/systemctl stop firewalld",
    logoutput => on_failure,
    unless    => "/usr/bin/systemctl status firewalld | grep 'inactive (dead)' " 
  }

  exec { 'disable-firewalld':
    command   => "/usr/bin/systemctl disable firewalld",
    logoutput => on_failure,
    unless    => "/usr/bin/systemctl status firewalld | grep 'service; disabled;' " 
  }


  ### selinux
  file_line { 'disable-seliux':
    ensure => present,
    path   => "/etc/selinux/config",
    line   => "SELINUX=disabled",
    match  => '^SELINUX\=',
  } 


  ### ntp
  package { 'ntp':
    ensure => installed,
  } ->
  service { 'ntpd': 
    enable  => true,
    ensure  => "running",
    require => Package['ntp']
  }

  ### java
  java::oracle { 'jdk' :
    ensure        => 'present',
    version_major => $java_version_major,
    version_minor => $java_version_minor,
    java_se       => 'jdk',
    url_hash      => $java_url_hash,
  } 

  ### mapr user, passwd is 'mapr'
  group { 'mapr':
    ensure => present,
    gid    => 5000,
  } ->
  user { 'mapr':
    ensure     => present,
    managehome => true,
    uid        => 5000,
    gid        => 'mapr',
    password   => '$6$lF68yer5CX$hGkROyp0TLcgNPHKCgXKb2Ckr27YV/7.Y.63dTjAHCCnaXYZXpelFXUZE5w.nbh4ugiMXXq5gtDwimd418ryV1',
  }

}
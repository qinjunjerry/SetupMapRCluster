# Class: profile::mapr::user
#
# This module creates users & groups
#

class profile::mapr::user (
) {

  ### jqin user
  group { 'jqin':
    ensure => present,
    gid    => 6000,
  } ->
  user { 'jqin':
    ensure     => present,
    managehome => true,
    uid        => 6000,
    gid        => 'jqin',
    password   => '$6$lF68yer5CX$hGkROyp0TLcgNPHKCgXKb2Ckr27YV/7.Y.63dTjAHCCnaXYZXpelFXUZE5w.nbh4ugiMXXq5gtDwimd418ryV1',
  }

  group { 'bigdata':
    ensure => present,
    gid    => 6100,
  }


  ### mike user
  group { 'mike':
    ensure => present,
    gid    => 6101,
  } ->
  user { 'mike':
    ensure     => present,
    managehome => true,
    uid        => 6101,
    gid        => 'mike',
    groups     => 'bigdata',
    password   => '$6$lF68yer5CX$hGkROyp0TLcgNPHKCgXKb2Ckr27YV/7.Y.63dTjAHCCnaXYZXpelFXUZE5w.nbh4ugiMXXq5gtDwimd418ryV1',
  }

  ### lisa user
  group { 'lisa':
    ensure => present,
    gid    => 6102,
  } ->
  user { 'lisa':
    ensure     => present,
    managehome => true,
    uid        => 6102,
    gid        => 'lisa',
    groups     => 'bigdata',
    password   => '$6$lF68yer5CX$hGkROyp0TLcgNPHKCgXKb2Ckr27YV/7.Y.63dTjAHCCnaXYZXpelFXUZE5w.nbh4ugiMXXq5gtDwimd418ryV1',
  }

}
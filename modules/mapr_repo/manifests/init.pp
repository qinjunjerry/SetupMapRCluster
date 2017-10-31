# Class: mapr_repo
#
# This module installs/configures MapR repo
#

class mapr_repo (
  $core_version = $mapr_repo::core_version,
  $mep_version  = $mapr_repo::mep_version,
) {

  exec { "import_mapr_gpg_key":
    command   => "/usr/bin/rpm --import http://package.mapr.com/releases/pub/maprgpg.key",
    logoutput => on_failure,
    unless    => "/usr/bin/rpm -qi gpg-pubkey-* | grep ^Packager | grep 'MapR Technologies' " 
  }


  file { 'mapr_repo_file':
    path    => '/etc/yum.repos.d/mapr.repo',
    ensure  => present,
    content => epp('mapr_repo/mapr.repo.epp'),
  }

}
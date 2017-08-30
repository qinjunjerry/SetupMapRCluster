# Class: mapr
#
# This module installs/configures the MapR cluster
#

class mapr (
  $mapr_version = $mapr::mapr_version,
  $mep_version  = $mapr::mep_version,
) {

  exec { "import_mapr_gpg_key":
    command   => "/usr/bin/rpm --import http://package.mapr.com/releases/pub/maprgpg.key",
    logoutput => on_failure,
    unless    => "/usr/bin/rpm -qi gpg-pubkey-* | grep ^Packager | grep 'MapR Technologies' " 
  }


  file { 'mapr_repo_file':
    path    => '/etc/yum.repos.d/mapr.repo',
    ensure  => present,
    content => epp('mapr/mapr.repo.epp'),
  }

}
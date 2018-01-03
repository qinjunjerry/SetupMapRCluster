# Class: profile::mapr::repo
#
# This module installs/configures MapR repo
#

class profile::mapr::repo (
  $core_version = $profile::mapr::repo::core_version,
  $mep_version  = $profile::mapr::repo::mep_version,
) {

  exec { "import_mapr_gpg_key":
    command   => "/usr/bin/rpm --import http://package.mapr.com/releases/pub/maprgpg.key",
    logoutput => on_failure,
    unless    => "/usr/bin/rpm -qi gpg-pubkey-* | grep ^Packager | grep 'MapR Technologies' "
  }


  file { 'mapr_repo_file':
    path    => '/etc/yum.repos.d/mapr.repo',
    ensure  => present,
    content => epp('profile/mapr/repo/mapr.repo.epp'),
  }
  ~>
  exec { 'yum clean all':
    command     => '/usr/bin/yum clean all',
    logoutput   => on_failure,
    refreshonly => true,
  }

}

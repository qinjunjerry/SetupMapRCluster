class bash_profile (
) {

  file { '/etc/profile.d/mbox.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/bash_profile/mbox.sh',
  }

}
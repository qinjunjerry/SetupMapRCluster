class profile::bash (
) {

  file { '/etc/profile.d/mbox.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('profile/bash/mbox.sh.epp'),
  }

}
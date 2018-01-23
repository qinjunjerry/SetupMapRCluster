class profile::bash (
) {

  file { '/etc/profile.d/mc.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('profile/bash/mc.sh.epp'),
  }

}

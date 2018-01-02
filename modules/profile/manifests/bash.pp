class profile::bash (
) {

  file { '/etc/profile.d/sema.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('profile/bash/sema.sh.epp'),
  }

}

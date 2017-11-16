class bash_profile (
) {

  file { '/etc/profile.d/mbox.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('bash_profile/mbox.sh.epp'),
  }

}
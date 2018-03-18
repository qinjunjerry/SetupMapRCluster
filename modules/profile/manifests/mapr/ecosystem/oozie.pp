# Class: profile::mapr::ecosystem::oozie
#
# This module installs/configures MapR oozie
#

class profile::mapr::ecosystem::oozie (
) {

  require profile::mapr::configure

  package { 'mapr-oozie':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

  if $profile::mapr::cluster::secure == true {

    $version = fact('mapr-oozie:version')

    # Needed to enable security for oozie server
    file_line { 'uncomment OOZIE_HTTPS_KEYSTORE_FILE in oozie-env.sh':
      ensure             => 'present',
      path               => "/opt/mapr/oozie/oozie-$version/conf/oozie-env.sh",
      line               => 'export OOZIE_HTTPS_KEYSTORE_FILE=/opt/mapr/conf/ssl_keystore',
      match              => '^#\s*export\s+OOZIE_HTTPS_KEYSTORE_FILE\=',
      append_on_no_match => false,
      notify             => Class['profile::mapr::warden_restart'],
      require            => [Package['mapr-oozie'], Exec['Run configure.sh -R']]
    }
    ->
    file_line { 'uncomment OOZIE_HTTPS_KEYSTORE_PASS in oozie-env.sh':
      ensure             => 'present',
      path               => "/opt/mapr/oozie/oozie-$version/conf/oozie-env.sh",
      line               => 'export OOZIE_HTTPS_KEYSTORE_PASS=mapr123',
      match              => '^#\s*export\s+OOZIE_HTTPS_KEYSTORE_PASS\=',
      append_on_no_match => false,
      notify             => Class['profile::mapr::warden_restart'],
      require            => [Package['mapr-oozie'], Exec['Run configure.sh -R']]
    }


    # Needed to enable security for oozie client
    file_line { 'uncomment OOZIE_CLIENT_OPTS in oozie-client-env.sh':
      ensure             => 'present',
      path               => "/opt/mapr/oozie/oozie-$version/conf/oozie-client-env.sh",
      line               => 'export OOZIE_CLIENT_OPTS="${OOZIE_CLIENT_OPTS} -Djavax.net.ssl.trustStore=/opt/mapr/conf/ssl_truststore"',
      match              => '^#\s*export\s+OOZIE_CLIENT_OPTS\=',
      append_on_no_match => false,
      require            => [Package['mapr-oozie'], Exec['Run configure.sh -R']]
    }

  }

}

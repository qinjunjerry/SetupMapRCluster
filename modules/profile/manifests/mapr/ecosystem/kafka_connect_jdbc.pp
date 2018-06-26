# Class: profile::mapr::ecosystem::kafka_connect_jdbc
#
# This module installs/configures MapR: kafka_connect_jdbc

class profile::mapr::ecosystem::kafka_connect_jdbc (
) {

  package { 'mapr-kafka-connect-jdbc':
    ensure  => present,
    notify  => Class['profile::mapr::configure_r']
  }

}

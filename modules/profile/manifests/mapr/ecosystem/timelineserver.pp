# Class: profile::mapr::ecosystem::timelineserver
#
# This module installs/configures MapR timelineserver
#

class profile::mapr::ecosystem::timelineserver (
) {

  include profile::kerberos
  include profile::mapr::cluster

  # mapr-timelineserver package installs the following files:
  #     /opt/mapr/conf/conf.d.new/warden.timelineserver.conf
  #     /opt/mapr/roles/timelineserver
  #     /opt/mapr/servicesconf/timelineserver

  package { 'mapr-timelineserver':
    ensure  => present,
  }


  if $profile::mapr::cluster::kerberos == true {
    # Needed by Timeline Server using Kerberos
    profile::hadoop::xmlconf_property {
      default:
        file    => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/yarn-site.xml',
        notify  => Class['profile::mapr::warden_restart'];

      # Enables cross-origin support (CORS) for web services
      'yarn.timeline-service.http-cross-origin.enabled': value => 'true';

      'yarn.timeline-service.keytab'                   : value => '/opt/mapr/conf/mapr.keytab';
      # kerberos realm is required if _HOST is used
      'yarn.timeline-service.principal'                : value => "mapr/_HOST@$profile::kerberos::default_realm";
      'yarn.timeline-service.http-authentication.kerberos.keytab'    : value => '/opt/mapr/conf/mapr.keytab';
      # kerberos realm is required if _HOST is used
      'yarn.timeline-service.http-authentication.kerberos.principal' : value => "HTTP/_HOST@$profile::kerberos::default_realm";
    }
  }


}
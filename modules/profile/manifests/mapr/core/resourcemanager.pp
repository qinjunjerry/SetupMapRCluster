# Class: profile::mapr::core::resourcemanager
#
# This module installs/configures MapR resourcemanager
#

class profile::mapr::core::resourcemanager (
) {

  require profile::mapr::prereq
  require profile::mapr::repo
  require profile::mapr::user

  package { 'mapr-resourcemanager':
    ensure  => present,
    notify  => Class['profile::mapr::configure'],
    before  => Class['profile::mapr::core::rm_nm_common'],
  }
  ->
  # Needed by Tez-UI cross-origin support (CORS) for web services
  profile::hadoop::xmlconf_property {
    default:
      file    => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml',
      notify  => Class['profile::mapr::warden_restart'];
      
    'org.apache.hadoop.security.HttpCrossOriginFilterInitializer': value => 'hadoop.http.filter.initializers';
  
  }
  ->
  profile::hadoop::xmlconf_property {
    default:
      file    => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/yarn-site.xml',
      notify  => Class['profile::mapr::warden_restart'];

    'yarn.resourcemanager.webapp.cross-origin.enabled': value => 'true';
  }  

}

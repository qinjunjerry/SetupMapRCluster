# Class: profile::mapr::core::rm_nm_common
#
# This module manages MapR resourcemanager and nodemanager common configurations
#

class profile::mapr::core::rm_nm_common (
) {

  include profile::kerberos
  include profile::mapr::cluster

  # Needed by Hive/Hue impersonation
  # https://maprdocs.mapr.com/52/Hive/HiveUserImpersonation-Enable.html
  profile::hadoop::xmlconf_property {
  	default:
      file   => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml',
      notify => Class['profile::mapr::warden_restart'];

    "hadoop.proxyuser.mapr.groups"     : value =>"*";
    "hadoop.proxyuser.mapr.hosts"      : value =>"*";
  }

  if $profile::mapr::cluster::kerberos == true {
    # Needed by Hue using Kerberos (YARN)
    profile::hadoop::xmlconf_property {
      default:
        file   => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/core-site.xml',
        notify => Class['profile::mapr::warden_restart'];

      'hue.kerberos.principal.shortname' : value => 'mapr';
    }

    # Needed by Hue to use Kerberos (YARN)
    # https://maprdocs.mapr.com/52/Hue/ConfigureHuetouseKerberosYARN.html
    profile::hadoop::xmlconf_property {
      default:
        file   => '/opt/mapr/hadoop/hadoop-2.7.0/etc/hadoop/yarn-site.xml',
        notify => Class['profile::mapr::warden_restart'];

      'yarn.resourcemanager.hostname'                  : value => '_HOST', ensure=>'absent';
      'yarn.resourcemanager.keytab'                    : value => '/opt/mapr/conf/mapr.keytab';
      # kerberos realm is required if _HOST is used
      'yarn.resourcemanager.principal'                 : value => "mapr/_HOST@$profile::kerberos::default_realm";
      'yarn.nodemanager.keytab'                        : value => '/opt/mapr/conf/mapr.keytab';
      # kerberos realm is required if _HOST is used
      'yarn.nodemanager.principal'                     : value => "mapr/_HOST@$profile::kerberos::default_realm";
      'yarn.nodemanager.container-executor.class'      : value => 'org.apache.hadoop.yarn.server.nodemanager.LinuxContainerExecutor';
      'yarn.nodemanager.linux-container-executor.group': value => 'mapr';

      'yarn.log-aggregation-enable'                    : value => 'true';
      # two days
      'yarn.log-aggregation.retain-seconds'            : value => '172800';
      # clean up local NM dir after 12 hours
      'yarn.nodemanager.delete.debug-delay-sec'        : value => '43200';

    }

    file_line {'MAPR_LOGIN_OPTS in /opt/mapr/conf/env.sh':
      ensure   => 'present',
      path     => '/opt/mapr/conf/env.sh',
      line     => 'MAPR_LOGIN_OPTS="-Dhadoop.login=hybrid -Dhttps.protocols=TLSv1.2 ${MAPR_JAAS_CONFIG_OPTS} ${MAPR_ZOOKEEPER_OPTS}"',
      match    => '^MAPR_LOGIN_OPTS\=',
    }
  }

}

# Class: profile::mapr::configure_r_tl
#
# This module runs configure.sh -R -TL
# This should be run on all hive nodes.
#

class profile::mapr::configure_r_tl (
) {

  include profile::mapr::cluster


  # append domain name to the hostname if not already done
  $timelineserver = join ( 
      split($profile::mapr::cluster::timelineserver,',').map |$item| { 
          if $item =~ /.+\..+/ { "$item" } else { "${item}.${profile::mapr::prereq::domain}" }
      },
  ',')

  exec { 'Run configure.sh -R -TL':
    command     => "/opt/mapr/server/configure.sh -R -TL $timelineserver",
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['profile::mapr::warden_restart2'],
    require     => Exec['Run configure.sh'],
  }

  # configure.sh -TL above add the following properties into yarn-site.xml:
  # yarn.timeline-service.enabled=true;
  # yarn.timeline-service.hostname=node67.ucslocal;
  # yarn.resourcemanager.system-metrics-publisher.enabled=true;
  # yarn.timeline-service.http-cross-origin.enabled=true;
  # yarn.timeline-service.http-authentication.type=com.mapr.security.maprauth.MaprDelegationTokenAuthenticationHandler;

}

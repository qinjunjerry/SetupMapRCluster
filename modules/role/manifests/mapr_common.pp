class role::mapr_common {
  include profile::mapr::prereq
  include profile::mapr::repo
  include profile::mapr::user
  include profile::mapr::configure
  include profile::mapr::configure_r
}
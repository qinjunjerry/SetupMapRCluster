class role::cluster_node {

  include role::mapr_common

  include profile::mapr::core::core
  include profile::mapr::core::zookeeper
  #include profile::mapr::core::cldb
  include profile::mapr::core::fileserver

  include profile::mapr::core::resourcemanager
  include profile::mapr::core::nodemanager
  include profile::mapr::core::rm_nm_common

  include profile::mapr::core::webserver

  include profile::mapr::sasl
  include profile::mapr::kerberos

  include profile::mapr::ecosystem::httpfs
  include profile::mapr::ecosystem::spark
  include profile::mapr::ecosystem::drill

  include profile::mapr::warden_restart

}

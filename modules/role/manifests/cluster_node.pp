class role::cluster_node {

  include role::cluster_node_core

  # monitoring
  include profile::mapr::ecosystem::collectd
  include profile::mapr::ecosystem::fluentd

  include profile::mapr::ecosystem::httpfs

  include profile::mapr::ecosystem::spark
  include profile::mapr::ecosystem::spark_conf

}

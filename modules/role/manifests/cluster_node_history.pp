class role::cluster_node_history {

  include role::cluster_node

  include profile::mapr::core::historyserver
  include profile::mapr::core::gateway

  include profile::mapr::ecosystem::spark_hdfs_env
  include profile::mapr::ecosystem::spark_historyserver

}

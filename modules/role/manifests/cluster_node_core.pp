class role::cluster_node_core {

  include role::mapr_common

  include profile::mapr::core::core
  include profile::mapr::core::fileserver
  # include profile::mapr::core::nfs

  include profile::mapr::core::nodemanager
  include profile::mapr::core::rm_nm_common
  # Configure NM local dir to the local volume on MapR FS
  # include profile::mapr::core::nm_local_dirs

  include profile::mapr::sasl
  include profile::mapr::kerberos

  include profile::mapr::warden_restart

  include profile::mapr::configure

}

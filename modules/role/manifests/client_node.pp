class role::client_node {
	include role::mapr_common
    include profile::mapr::configure_c

	include profile::mapr::client
}

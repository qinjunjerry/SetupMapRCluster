# Class: profile::mapr::core::nfs
#
# This module installs/configures MapR nfs
#

class profile::mapr::core::nfs (
) {

	package { 'perl':
		ensure => installed,
	}
	->
	package { 'mapr-nfs':
		ensure => installed,
	}

}
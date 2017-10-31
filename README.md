# Setup an Unsecure/Secure MapR Cluster with Puppet

## Prerequisites

- The entire directory must to be downloaded to the node where MapR is to be installed. 
- The user who run this script must be root or can sudo to root

## Steps

- Change into the directory
  `cd /MapRSetup`
- Install puppet and puppet modules
  `sh bootstrap.sh`
- Set variables (e.g., cluster name, MapR version, etc.) in:
	- `hiera/common.yaml` for common settings
	- `hiera/nodes/<nodename>.yaml` for node specific settings
- For MapR SASL secured cluster
  - Prepare `cldb.key`, `maprserverticket`, `ssl_keystore`, `ssl_truststore`
- For Kerberos secured cluster
  - Prepare `krb5.conf`, `mapr.keytab`
- Install and configure MapR
  `sh install_mapr.sh`
- Start MapR cluster
  `systemctl start mapr-zookeeper && systemctl start mapr-warden`

## Known issues
- This script currently runs only under /MapRSetup

## TODO
- Reboot after selinux change
- Setup from any directory like /home/ec2-user

## Overview of Modules
- mapr_pre      : prerequisites (OS settings, 'mapr' account and its settings)
- mapr_repo     : yum/apt repo
- mapr_user     : additional users
- mapr_core     : core packages, mfs, cldb, etc.
- mapr_sasl     : configure MapR SASL
- mapr_kerberos : configure Kerberos 
- mapr_config   : generate and run configure.sh


## Steps to create a VM

- Create a directory to hold the VM on datastore 'VM'
- Copy VM template (nodeNN.vmx, nodeNN.vmdk) from datastore 'Home'
- Select vmx file and right click to add into vSphere Inventory
- Boot up the VM, run commands:
  - vi /etc/sysconfig/network-scripts/ifcfg-ens192
  	ONBOOT="YES"
  	IPADDR="<IPADDR>"
  - systemctl restart network
  - hostnamectl set-hostname <nodeNN>
  - vi /etc/selinux/config
  	SELINUX=disabled
  - yum update -y
  - reboot
- ssh-copy-id <nodeNN>
- ssh <nodeNN>  
- Thin provision a 32GB disk in datastore

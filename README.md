# Setup MapR cluster with puppet

## Prerequisites

- The entire directory must to be copied to the node where MapR is to be installed. 
  You can simply run: rsync -avz <this_dir> <node>:/
- The user who run this script must be root or can sudo to root  


## Steps

- sh bootstrap.sh
- set variables in:
	- hiera/common.yaml       for common settings
	- hiera/nodes/<node>.yaml for node specific settings
- sh install_mapr.sh
- sh configure_mapr.sh

## Known issues:

- This script currently runs only under /MapRSetup

## TODO:
- reboot after selinux change, then no reboot between install mapr packages and configure.sh
- packages::toremove
- mapr_pre for client nodes
- disable firewalld only it exsits
- setup from non-root user:
	- hiera.yaml: /MapRSetup
	- mapr_pre/manifests/init.pp: /MapRSetup

## Setup an Unsecure/Secure MapR Cluster with Puppet

### Prerequisites

- The entire directory must to be downloaded to the node where MapR is to be installed. 
- The user who run this script must be root or can sudo to root

### Steps

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

### Known issues
- This script currently runs only under /MapRSetup

### Overview of Puppet Modules
- `mapr_pre`      : prerequisites (OS settings, 'mapr' account and its settings)
- `mapr_repo`     : yum/apt repo
- `mapr_user`     : additional users
- `mapr_core`     : core packages, zookeeper, mfs, etc.
- `mapr_cldb`     : install and configure cldb
- `mapr_sasl`     : create MapR SASL related files: cldb.key, maprserverticket, ssl_keystore, ssl_truststore
- `mapr_kerberos` : configure Kerberos: krb5.conf, mapr.keytab 
- `mapr_config`   : run configure.sh -C ... -Z ...
- `mapr_httpfs`   : install and configure httpfs
- `mapr_config_r` : run configure.sh -R

### TODO
- Add property/value to XML file
- Setup from any directory like /home/ec2-user
- Generate MapR SASL files without install first
- Reboot after selinux change


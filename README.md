## Setup an Unsecure/Secure MapR Cluster with Puppet

### Prerequisites

- The entire directory must be downloaded to the node where MapR is to be installed.
- The user who runs this script must be root or can sudo to root

### Steps

- Set variables (e.g., cluster name, MapR version, etc.) in:
	- `hiera/common.yaml` for common settings
	- `hiera/nodes/<nodename>.yaml` for node specific settings
- For MapR SASL secured cluster
  - Copy `cldb.key`, `maprserverticket`, `ssl_keystore`, `ssl_truststore` to `input/`
- For Kerberos secured cluster
  - Copy `krb5.conf` to `input/`
  - Copy `mapr.keytab` to `input/`
    - `mapr.keytab` must contain the principal `mapr/<clustername>`
    - and also the principals `HTTP/<node>` and `mapr/<node>`, if httpfs kerberos authentication is configfured
- Install puppet and puppet modules
  `maprbox init`
- Install and configure MapR
  `maprbox setup`
- Start MapR cluster
  `maprbox start`

### FAQ

#### How to update properties in a hadoop xml configuration file?
Include the following into the corresponding module, for example for module mapr_httpfs:

  ```
  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"

  package { ... }
  ->
  mapr_util::hadoop_xml_conf {
    # add a property
    "property_name1": file=>$file, value =>"value1", description=>"description1", ensure=>"present";
    # shorthand
    "property_name2": file=>$file, value =>"value2";
    # remove a property
    "property_name3": file=>$file, ensure=>"absent";
 }
 ```

### Overview of Puppet Modules
- `mapr_pre`      : prerequisites (OS settings, 'mapr' account and its settings)
- `mapr_repo`     : yum/apt repo
- `mapr_user`     : additional users
- `mapr_cldb`     : install and configure cldb
- `mapr_sasl`     : create MapR SASL related files: cldb.key, maprserverticket, ssl_keystore, ssl_truststore
- `mapr_kerberos` : configure Kerberos: krb5.conf, mapr.keytab
- `mapr_config`   : run configure.sh -C ... -Z ...
- `mapr_httpfs`   : install and configure httpfs
- `mapr_config_r` : run configure.sh -R

### TODO
- Require some class before run configure.sh
- Run actions only after cluster is started, e.g., hadoop fs
- Setup from any directory like /home/ec2-user
- Generate MapR SASL files without install first
- Reboot after selinux change
- Dynamically check package verions, e.g., spark-2.1.0 in order to determine spark_home
- Run actions on one node only: spark.yarn.archive


## Setup an Unsecure/Secure MapR Cluster with Puppet

### Prerequisites

- The entire directory must be downloaded and copied to the node where MapR is to be installed.
- The user who runs this script must be root or can sudo to root

### Steps

- Set variables (e.g., cluster name, MapR version, etc.) in:
	- `hieradata/common.yaml` for common settings
	- `hieradata/nodes/<nodename>.yaml` for node specific settings
- For MapR SASL secured cluster
  - Copy `cldb.key`, `maprserverticket`, `ssl_keystore`, `ssl_truststore` to `inputfiles/`
- For Kerberos secured cluster
  - Copy `krb5.conf` to `inputfiles/`
  - Copy `mapr.keytab` to `inputfiles/`
    - `mapr.keytab` must contain the principal `mapr/<clustername>`
    - and if httpfs kerberos authentication is configfured:
      - `mapr.keytab` must also contain the principals `HTTP/<node>` and `mapr/<node>`
      - `mapr.keytab` must be copied to `inputfiles/<nodename>`
- Install puppet and puppet modules
  `mbox init`
- Install configure and start MapR
  `mbox setup`
- Or combine both steps above with:
  `mbox up`

### FAQ

#### How to update properties in a hadoop xml configuration file?
Include the following into the corresponding module, for example for module profile::mapr::ecosystem::httpfs:

  ```
  $file = "/opt/mapr/httpfs/httpfs-1.0/etc/hadoop/httpfs-site.xml"

  package { ... }
  ->
  profile::hadoop::xmlconf_property {
    # add a property
    "property_name1": file=>$file, value =>"value1", description=>"description1", ensure=>"present";
    # shorthand
    "property_name2": file=>$file, value =>"value2";
    # remove a property
    "property_name3": file=>$file, ensure=>"absent";
 }
 ```

### TODO
- Do not hardcode active instance in configuration, e.g. resourcemanager_api_url and webhdfs_url in hue.ini

## Setup MapR Clusters with Puppet

### Overview

This tool facilitates the setup of MapR clusters using Puppet. Starting from a fresh installed OS. It downloads & installs puppet and then runs 'puppet apply' (aka. puppet master-less mode) to do the setup. There is no need for any puppet infrastructure in place in advance.

The purpose is to provide a tool such that one can setup & configure an unsecure or MapR-SASL/Kerberos secured MapR cluster in the way he/she wants in a few steps. And once the configuration has been added into puppet hiera, the same/similar cluster can be setup with one command `sema up`.

This tool development is in progress. Not all ecosystem components have been added. You are welcome to contribute via pull requests :)

### Steps

- Download or `git clone` this tool to a directory on your workstation
- Decide your cluster name and create the subdirectory: `hieradata/<clustername>`
- Review the variables in `hieradata/default.yaml` (e.g., cluster name, MapR core and MEP version, etc.) and override them in `hieradata/<clustername>/cluster.yaml`
  - You can set variables in `hieradata/default.yaml` directly if you manage **only one** cluster with this tool
- For each node in your cluster, create `hieradata/<clustername>/<nodefqdn>.yaml`, add the profiles/roles you want to have on that node
- For a secure cluster, generate the needed files on node70 (10.10.70.70):
  - `cd /root/intputfiles`
  - For MapR SASL secured cluster, generate cldb key files:
    - `/root/MapRSetup/utils/create_cldb_keyfile.sh <clustername> <dnsdomain>`
  - For Kerberos secured cluster, generate kerberos keytab files
      - `cd /root/intputfiles`
      - `/root/MapRSetup/utils/create_principal_keytab.sh <clustername> <dnsdomain> node1 node2 ...`
  - Copy `node70:/root/intputfiles/<clustername>` to `inputfiles/`
- Copy the entire prepared directory to each individual node
- To install puppet and puppet modules, run under `root` or an account which can sudo to root:
  `sema init`
- To install configure and start the MapR cluster, run under `root` or an account which can sudo to root:
  `sema setup`
- Or combine both steps above with:
  `sema up`

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
#### How to solve "shell-init: error retrieving current directory ... unhandled exception: boost::filesystem::current_path: No such file or directory"?

You may see the following error when run 'sema setup'/'sema up':

    shell-init: error retrieving current directory: getcwd: cannot access parent directories: No such file or directory
    2017-12-04 16:46:09.627479 FATAL puppetlabs.facter - unhandled exception: boost::filesystem::current_path: No such file or directory
    terminate called after throwing an instance of 'boost::filesystem::filesystem_error'
    what():  boost::filesystem::current_path: No such file or directory

The reason is that the working directory where you run sema has been removed in a different shell session or by a different app. Change to any existing directory should solve the issue.

### Limitations
- This tool now supports only CentOS/RedHat.
- To setup a kerberized cluster, this tool uses node70 as the KDC. This works only in our UCS env. To do the setup in a cloud env, one can setup a simliar node like node70 with this tool, referring to hieradata/nodes/node70.ucslocal.yaml.

### TODO
- Add more ecosystem component and their configurations


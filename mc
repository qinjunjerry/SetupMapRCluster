#!/bin/sh

mc_help() {
  cat << EOF
Usage: $0 command

Common commands:
   help            shows this help

   init            bootstrap: installs puppet, r10k, and puppet modules
   setup [cluster] install, configure and start MapR
   up    [cluster] init + setup

   start           start mapr-zookeeper and then mapr-warden
   stop            stop mapr-warden and then mapr-zookeeper
   restart         stop + start

   delmapr         remove mapr packages and /opt/mapr
   delpuppet       remove puppet

   clean           stop + delmapr
   cleanall        stop + delmapr + delpuppet

   pi              run MapReduce pi job
   sparkpi         run SparkPi job
EOF
}

# The base dir of mc
BASE_DIR=$(dirname $(readlink -f $0))
# The dir to download external (i.e., 3rd party) puppet modules
EXTERNAL=$BASE_DIR/external

mc_init() {
    # install puppet repo
    if rpm -qa | grep puppet5-release >/dev/null; then
        echo "puppet5-release already installed"
    else
        sudo rpm -Uvh https://yum.puppetlabs.com/puppet5/puppet5-release-el-7.noarch.rpm
    fi

    # install puppet agent
    if rpm -qa | grep puppet-agent >/dev/null; then
        echo "puppet-agent already installed"
    else
        sudo yum install -y puppet-agent
    fi

    # install r10k from Ruby Gems
    if /opt/puppetlabs/puppet/bin/gem list | grep r10k >/dev/null; then
        echo "puppet gem r10k already installed"
    else
        # Limit to version 2.6.4
        # r10k 3.0.0 has a bug: https://tickets.puppetlabs.com/browse/RK-327
        # sudo /opt/puppetlabs/puppet/bin/gem install r10k -v 2.6.4
        # Update on Sep 27, 2018: this bug is fixed in r10k 3.0.1
        sudo /opt/puppetlabs/puppet/bin/gem install r10k
    fi

    # download external puppet modules
    if ls $EXTERNAL/stdlib >/dev/null 2>&1; then
        echo "puppet modules stdlib etc. already installed"
    else
        sudo /opt/puppetlabs/puppet/bin/r10k puppetfile install --puppetfile $BASE_DIR/Puppetfile --moduledir $EXTERNAL
    fi
}

get_cluster_setting() {
    cluster=$1
    property=$2

    value=
    if [ -f $BASE_DIR/hieradata/$cluster/cluster.yaml ]; then
        value=`grep ^$property $BASE_DIR/hieradata/$cluster/cluster.yaml | awk '{print $NF}'`
    fi
    # if not found, get it from default.yaml
    if [ -z $value ]; then
        value=`grep ^$property $BASE_DIR/hieradata/default.yaml | awk '{print $NF}'`
    fi
    echo $value
}

mc_setup() {
    # set cluster fact if given, the fact is used in heira.yaml
    if [ -f /opt/mapr/conf/mapr-clusters.conf ]; then
        cluster=`cat /opt/mapr/conf/mapr-clusters.conf | head -1 | awk '{print $1}'`
        echo "INFO: cluster=$cluster, from /opt/mapr/conf/mapr-clusters.conf"
    elif [ ! -z $1 ]; then
        cluster=$1
        echo "INFO: cluster=$cluster, from command line"
    fi

    if [ -z $cluster ]; then
        # this is used to setup nodes like KDC
        echo "INFO: setup non-cluster node. Specify 'cluster' at command line to setup a cluster node."
    else
        export FACTER_cluster=$cluster

        ### create external facter script package_version.py based on mep version and os.family
        # get mep version
        mep_version=`get_cluster_setting $cluster profile::mapr::repo::mep_version`
        if [ -z "$mep_version" ]; then
            echo "Error: mep_version not found. Exit now."
            exit 1
        fi
        # get os.family
        os_family=`/opt/puppetlabs/bin/facter os.family | tr [:upper:] [:lower:]`
        if [ -z "$os_family" ]; then
            echo "Error: os_family not found. Exit now."
            exit 1
        fi
        # create external facter script package_version.py
        version_script=$BASE_DIR/utils/package_version.py
        fact_script=$BASE_DIR/modules/profile/facts.d/package_version.py
        sed -e "s/MEP_VERSION/$mep_version/g" -e "s/OS_FAMILY/$os_family/g" $version_script > $fact_script
        chmod +x $fact_script

        ### get dns domain and add fqdn to /etc/hosts
        dnsdomain=`get_cluster_setting $cluster profile::mapr::prereq::domain`
        if ! grep -q `hostname`.$dnsdomain /etc/hosts; then
            echo `hostname -I` `hostname`.$dnsdomain `hostname` >> /etc/hosts
        fi
    fi
    # run puppet apply
    ENVIRON=production
    # adding prefix 'FACTER_' to make $base_dir available in puppet manifests
    # using 'sudo -E' to preserve env variables
    export FACTER_base_dir=$BASE_DIR
    sudo -E /opt/puppetlabs/bin/puppet apply --show_diff --graph \
        --modulepath $BASE_DIR/modules:$EXTERNAL \
        --hiera_config $BASE_DIR/hiera.yaml \
        --environmentpath=$BASE_DIR/environments \
        --environment=$ENVIRON \
        $BASE_DIR/environments/$ENVIRON/manifests/default.pp
}

mc_start() {
    sudo systemctl daemon-reload
    if rpm -qa | grep -q mapr-zookeeper; then
        sudo systemctl start mapr-zookeeper && sudo systemctl start mapr-warden
    else
        sudo systemctl start mapr-warden
    fi
}

mc_stop() {
    sudo systemctl daemon-reload
    if rpm -qa | grep -q mapr-zookeeper; then
        sudo systemctl stop mapr-warden && sudo systemctl stop mapr-zookeeper
    else
        sudo systemctl stop mapr-warden
    fi   
    if ps -fu mapr >/dev/null; then
        echo "Sleep 10 sec ..."
        sleep 10s
        echo "Force kill the remaining proceses"
        ps -fu mapr --no-header| grep -v bash | awk '{print $2}' | xargs kill -9
    fi

    echo "[VERIFY] check running mapr processes ..."
    if ps -fu mapr; then
        false
    else
        true
    fi

}

mc_restart() {
    mc_stop && mc_start
}

mc_delmapr() {
    sudo yum erase -y mapr-\*
    sudo rm -fr /opt/mapr /etc/yum.repos.d/mapr.repo
    echo "[VERIFY] check installed mapr packages ..."
    rpm -qa | grep mapr
}

mc_delpuppet() {
    sudo yum erase -y puppet-agent puppet5-release
    sudo rm -fr /opt/puppetlabs
}

mc_up() {
    mc_init && mc_setup $1
}

mc_clean() {
    mc_stop && mc_delmapr
    echo "[VERIFY] check running mapr processes ..."
    if ps -fu mapr; then
        false
    else
        true
    fi
}

mc_cleanall() {
    mc_clean && mc_delpuppet
}


mc_ldir() {
    declare -a dir_array=(`ls -d /opt/mapr/*/*-*/{logs,conf,etc/hadoop,etc/conf,desktop/conf,var/log} 2>/dev/null`)

    for ((i=0; i<${#dir_array[@]}; i++)); do
        printf "%2d = %s\n" $i ${dir_array[$i]}
    done

    #read -p "Select dir: " i
}


mc_pi() {    
    exec_cmd "sudo -u mapr hadoop jar /opt/mapr/hadoop/hadoop-2.7.0/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.7.0-mapr-*.jar pi -Dfs.mapr.trace=debug 10 100"
}

mc_sparkpi() {
    exec_cmd "sudo -u mapr /opt/mapr/spark/spark-*/bin/run-example --master yarn --deploy-mode client --verbose SparkPi 10"
}

exec_cmd() {
    echo Run: $1
    eval "$1"
}

mc_clean_data() {
    rm -fr /opt/mapr/zkdata/version-2
    rm -f /opt/mapr/conf/disktab
    rm -f /opt/mapr/pid/*.pid
}

mc_backup_ids() {
    dir=/root/cluster.backup.`date +%Y-%m-%d`
    mkdir -p $dir
    cp /opt/mapr/hostname       $dir
    cp /opt/mapr/hostid         $dir
    cp /opt/mapr/conf/clusterid $dir
    cp /opt/mapr/conf/disktab   $dir
}

##### ##### main ##### #####

if [ $# -eq 0 ]; then
    mc_help
    exit 1
fi

commandList=(help init setup up start stop restart delmapr delpuppet clean cleanall ldir pi sparkpi)
command=$1
shift
if [[ " ${commandList[*]} " == *" $command "* ]]; then
    mc_$command $@
else
    echo Error: invalid command: $command
    echo
    mc_help
fi

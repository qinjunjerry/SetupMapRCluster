# Class: profile::mapr::ecosystem::drill_on_yarn
#
# This module installs/configures MapR drill_on_yarn
#

class profile::mapr::ecosystem::drill_on_yarn (
) {


}


# yum install mapr-drill-yarn
# 
# make sure mapr can write into: /opt/mapr/drill to create drillbit cluster pid file:
# /opt/mapr/drill/drill-coco_cluster-drillbits.appid
# /opt/mapr/drill/site
# 
# export DRILL_HOME=/opt/mapr/drill/drill-1.13.0
# export DRILL_SITE=/opt/mapr/drill/site
# mkdir -p $DRILL_SITE
# 
# copy are mapr user:
# cp $DRILL_HOME/conf/drill-override.conf $DRILL_SITE
# cp $DRILL_HOME/conf/drill-env.sh $DRILL_SITE
# cp $DRILL_HOME/conf/drill-on-yarn.conf $DRILL_SITE
# cp $DRILL_HOME/conf/distrib-env.sh $DRILL_SITE
# 
# make sure zookeeper connect is set correct in drill-override.conf
# 
# drill-on-yarn.conf: keep the default memory/CPU/disk settings: 3 + 3 + 1 + 1 = 8GB
# 
# leave yarn.scheduler.maximum-allocation-mb also at its default size 8GB
# 
# create this file to prevent drill bit tmp file from being cleaned up
# cat /etc/tmpfiles.d/exclude-nm-local-dir.conf
# x /tmp/hadoop-mapr/nm-local-dir/*
# 
# if need secured drill-on-yarn, other settings are also needed:
#  drill-override.conf
#  /etc/pam.d/drill
#  /opt/mapr/jpam/lib
#  drill-env.sh
# Also make sure the user who starts dill-on-yarn are also in shadow group.
# 
# To start as mapr user: 
# - make sure a valid mapr ticket exists
# - DRILL/bin/drill-on-yarn.sh --site /opt/mapr/drill/site start
# To start as a different user (e.g., with another user's ticket)
# make sure: 
# chmod 777 /mapr/coco.cluster/user/drill
# rm /mapr/coco.cluster/user/drill/*
# rm -fr /tmp/drill
# create user's home in MapR FS
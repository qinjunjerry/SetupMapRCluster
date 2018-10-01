#!/bin/sh

# This script check whether NodeManager is ready

LOGFILE=/tmp/ensure_nodemanager_ready.log
echo > $LOGFILE
while ! jps | grep NodeManager 2>&1 >>$LOGFILE; do
	echo `date`: sleep 10 >> $LOGFILE
	sleep 10
done
echo `date`: "NodeManager is up, check /var/mapr/local/$(hostname -f)" >> $LOGFILE
while ! hadoop fs -test -d /var/mapr/local/$(hostname -f) 2>&1 >>$LOGFILE; do
	echo `date`: sleep 10 >> $LOGFILE
	sleep 10
done

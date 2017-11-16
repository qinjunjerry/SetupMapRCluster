#!/bin/sh

# This script assumes:
# - cldb start has been triggered from warden
# - a mapr ticket has been created (or can be created from a kerberos ticket),
#   if security is enabled

LOGFILE=/tmp/ensure_cldb_ready.log
echo > $LOGFILE
while ! maprcli node cldbmaster 2>&1 >>$LOGFILE; do
	echo `date`: sleep 10 >> $LOGFILE
	sleep 10
done
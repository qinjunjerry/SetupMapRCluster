#!/bin/sh

# This script is supposed to be called after warden triggers the cldb start
# and a mapr/kerberos ticket exists if security is enabled

while ! maprcli node cldbmaster 2>&1 >/dev/null; do
	sleep 10
done
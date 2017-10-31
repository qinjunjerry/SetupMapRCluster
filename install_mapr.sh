#!/bin/sh

DIR=$(dirname $0)
ENVIRON=production
/opt/puppetlabs/bin/puppet apply \
	--modulepath $DIR/modules/:$DIR/external \
	--hiera_config $DIR/hiera.yaml \
	--environmentpath=$DIR/environments \
	--environment=$ENVIRON \
	$DIR/environments/$ENVIRON/manifests/default.pp

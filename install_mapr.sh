#!/bin/sh

DIR=$(dirname $0)
/opt/puppetlabs/bin/puppet apply --modulepath $DIR/modules/:$DIR/external --hiera_config $DIR/hiera.yaml --environmentpath=$DIR/environments --environment=production $DIR/environments/production/manifests/default.pp

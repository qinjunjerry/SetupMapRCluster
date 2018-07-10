#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 cluster hivemeta_node_fqdn
    exit 1
fi

CLUSTER=$1
META_NODE=$2

META_DB=`echo $CLUSTER | tr . _`
META_NODE_SHORT=`echo $2 | cut -d. -f 1`



echo "\
DROP DATABASE metastore_$META_DB; \
DROP USER hive@$META_NODE; \
DROP USER hive@$META_NODE_SHORT; \
" | mysql -u root --password=

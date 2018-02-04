#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 cluster hivemeta_node
    exit 1
fi

CLUSTER=$1
META_NODE=$2
META_DB=`echo $CLUSTER | tr . _`



echo "\
DROP DATABASE metastore_$META_DB; \
DROP USER hive@$META_NODE; " | mysql -u root --password=

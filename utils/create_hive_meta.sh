#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 cluster hivemeta_node
    exit 1
fi

CLUSTER=$1
META_NODE=$2
META_DB=`echo $CLUSTER | tr . _`


echo "\
CREATE USER hive@$META_NODE IDENTIFIED BY 'password'; \
CREATE DATABASE metastore_$META_DB; \
REVOKE ALL PRIVILEGES, GRANT OPTION FROM hive@$META_NODE; \
GRANT ALL PRIVILEGES ON metastore_$META_DB.* TO hive@$META_NODE; \
FLUSH PRIVILEGES;" | mysql -u root --password=

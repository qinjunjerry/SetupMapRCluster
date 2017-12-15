#!/bin/sh

if [ $# -lt 3 ]; then
    echo Usage: $0 cluster dnsdomain node [node ...]
    exit 1
fi

delete_principal() {
    principal=$1

    if kadmin.local -q 'listprincs' | grep -q ${principal}@; then
        kadmin.local -q "delprinc -force $principal"
    else
        echo principal $principal not found
    fi
}

CLUSTER_NAME=$1
DOMAIN_NAME=$2

delete_principal mapr/$CLUSTER_NAME

shift
shift

for node in $*; do
    node=$node.$DOMAIN_NAME

    delete_principal mapr/$node
    delete_principal HTTP/$node

    rm -fr $CLUSTER_NAME/$node
done


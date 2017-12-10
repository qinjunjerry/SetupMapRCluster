#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 user password
    exit 1
fi

create_principal() {
    principal=$1
    passwd=$2

    if [ "x$passwd" != "x" ]; then
        passwd="-pw $passwd"
    else
        passwd="-randkey"
    fi

    if kadmin.local -q 'listprincs' | grep -q ${principal}@; then
        echo principal $principal aleady exits
    else
        kadmin.local -q "addprinc $passwd $principal"
    fi
}

USER_NAME=$1
PASSWORD=$2

create_principal $USER_NAME $PASSWORD
rm -f ${USER_NAME}.keytab
kadmin.local -q "ktadd -norandkey -k ${USER_NAME}.keytab $USER_NAME"

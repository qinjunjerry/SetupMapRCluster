#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 cluster dnsdomain
    exit 1
fi

CLUSTER_NAME=$1
CERT_NAME=*.$2

mkdir -p $CLUSTER_NAME/

if [ -e cldb.key -o -e maprserverticket -o -e ssl_keystore -o -e ssl_truststore ]; then
	echo At least one of cldb.key, maprserverticket, ssl_keystore, and ssl_truststore exists, exiting now.
	exit 1
fi

if [ `pwd` = '/opt/mapr/conf' ]; then
	echo This script must not run from /opt/mapr/conf, to avoid overriding existing cluster key files
	exit 1
fi

# cldb.key
/opt/mapr/bin/maprcli security genkey -keyfile $CLUSTER_NAME/cldb.key

# maprserverticket
/opt/mapr/bin/maprcli security genticket -inkeyfile $CLUSTER_NAME/cldb.key -ticketfile $CLUSTER_NAME/maprserverticket -cluster $CLUSTER_NAME -maprusername mapr -mapruid 5000 -maprgid 5000

### generate ssl key/truststore
sslKeyStore=$CLUSTER_NAME/ssl_keystore
sslTrustStore=$CLUSTER_NAME/ssl_truststore

storePass=mapr123
storeFormat=JKS

if [ "$JAVA_HOME"x = "x" ]; then
  KEYTOOL=`which keytool`
else
  KEYTOOL=$JAVA_HOME/bin/keytool
fi

# Check if keytool is actually valid and exists
if [ ! -e "${KEYTOOL:-}" ]; then
    echo "The keytool in \"${KEYTOOL}\" does not exist."
    echo "Keytool not found or JAVA_HOME not set properly. Please install keytool or set JAVA_HOME properly."
    exit 1
fi


# ssl_keystore
# create self signed certificate with private key
echo "Creating 10 year self signed certificate with subjectDN=CN=$CERT_NAME"
$KEYTOOL -genkeypair -sigalg SHA512withRSA -keyalg RSA -alias $CLUSTER_NAME -dname CN=$CERT_NAME -validity 3650 \
       -storepass $storePass -keypass $storePass \
       -keystore $sslKeyStore -storetype $storeFormat
if [ $? -ne 0 ]; then
    echo "Keytool command to generate key store failed"
    exit 1
fi

# ssl_truststore
# extract self signed certificate into trust store
tmpfile=$sslTrustStore.tmp
rm -f $tmpfile
$KEYTOOL -exportcert -keystore $sslKeyStore -file $tmpfile \
       -alias $CLUSTER_NAME -storepass $storePass -storetype $storeFormat
if [ $? -ne 0 ]; then
    echo "Keytool command to extract certificate from key store failed"
    exit 1
fi
$KEYTOOL -importcert -keystore $sslTrustStore -file $tmpfile \
        -alias $CLUSTER_NAME -storepass $storePass -noprompt
if [ $? -ne 0 ]; then
    echo "Keytool command to create trust store failed"
    exit 1
fi
rm -f $tmpfile

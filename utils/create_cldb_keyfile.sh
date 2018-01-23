#!/bin/sh

if [ $# -lt 2 ]; then
    echo Usage: $0 cluster dnsdomain node [node ...]
    exit 1
fi

CLUSTER_NAME=$1
DNS_DOMAIN=$2
shift
shift
nodes=$*

mkdir -p $CLUSTER_NAME/

if [ -e $CLUSTER_NAME/cldb.key -o -e $CLUSTER_NAME/maprserverticket ]; then
	echo At least one of $CLUSTER_NAME/cldb.key, $CLUSTER_NAME/maprserverticket exists, exiting now.
	exit 1
fi

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

# cldb.key
/opt/mapr/bin/maprcli security genkey -keyfile $CLUSTER_NAME/cldb.key

# maprserverticket
/opt/mapr/bin/maprcli security genticket -inkeyfile $CLUSTER_NAME/cldb.key -ticketfile $CLUSTER_NAME/maprserverticket -cluster $CLUSTER_NAME -maprusername mapr -mapruid 5000 -maprgid 5000

### generate ssl key/truststore
storePass=mapr123
storeFormat=JKS

for node in $nodes; do

  CERT_NAME=$node.$DNS_DOMAIN

  mkdir -p $CLUSTER_NAME/$CERT_NAME

  sslKeyStore=$CLUSTER_NAME/$CERT_NAME/ssl_keystore
  sslTrustStore=$CLUSTER_NAME/$CERT_NAME/ssl_truststore

  IP_ADDR=`cat /etc/hosts | grep -w $node | awk '{print $1}'`

  # ssl_keystore
  # create self signed certificate with private key
  echo "Creating 10 year self signed certificate with subjectDN=CN=$CERT_NAME"
  $KEYTOOL -genkeypair -sigalg SHA512withRSA -keyalg RSA -alias $node.$CLUSTER_NAME -dname CN=$CERT_NAME -validity 3650 \
         -ext "san=dns:$node,ip:$IP_ADDR" \
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
         -alias $node.$CLUSTER_NAME -storepass $storePass -storetype $storeFormat
  if [ $? -ne 0 ]; then
      echo "Keytool command to extract certificate from key store failed"
      exit 1
  fi
  $KEYTOOL -importcert -keystore $sslTrustStore -file $tmpfile \
          -alias $node.$CLUSTER_NAME -storepass $storePass -noprompt
  if [ $? -ne 0 ]; then
      echo "Keytool command to create trust store failed"
      exit 1
  fi
  rm -f $tmpfile

done

### merge individual truststore into one
read -r -a node_array <<< "$nodes"
mv $CLUSTER_NAME/${node_array[0]}.$DNS_DOMAIN/ssl_truststore $CLUSTER_NAME/
for node in ${node_array[@]:1}; do
    /opt/mapr/server/manageSSLKeys.sh merge $CLUSTER_NAME/$node.$DNS_DOMAIN/ssl_truststore $CLUSTER_NAME/ssl_truststore
    rm $CLUSTER_NAME/$node.$DNS_DOMAIN/ssl_truststore
done

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
echo generating cldb.key ...
/opt/mapr/bin/maprcli security genkey -keyfile $CLUSTER_NAME/cldb.key

# maprserverticket
echo generating maprserverticket ...
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

  ###
  # We need use $CLUSTER_NAME as an alias in ssl_keystore because
  # 1. /opt/mapr/grafana/grafana-4.4.2/bin/configure.sh (in MapR 6) expects $CLUSTER_NAME as an alias in ssl_keystore
  # 2. /opt/mapr/hue/hue-3.12.0/bin/secure.sh expects $CLUSTER_NAME as alias in ssl_keystore
  #
  # We need use $node.$DNS_DOMAIN as the alias in ssl_truststore as we may need merge all truststores from multiple 
  # clusters into one
  #
  echo generating $node ssl_keystore ...
  $KEYTOOL -genkeypair -sigalg SHA512withRSA -keyalg RSA -alias $CLUSTER_NAME -dname CN=$CERT_NAME -validity 3650 \
         -ext "san=dns:$node,dns:$node.$DNS_DOMAIN,ip:$IP_ADDR" \
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
  echo extracting $node ssl_truststore ...
  $KEYTOOL -exportcert -keystore $sslKeyStore -file $tmpfile \
         -alias $CLUSTER_NAME -storepass $storePass -storetype $storeFormat
  if [ $? -ne 0 ]; then
      echo "Keytool command to extract certificate from key store failed"
      exit 1
  fi
  $KEYTOOL -importcert -keystore $sslTrustStore -file $tmpfile \
          -alias $node.$DNS_DOMAIN -storepass $storePass -noprompt
  if [ $? -ne 0 ]; then
      echo "Keytool command to create trust store failed"
      exit 1
  fi
  rm -f $tmpfile

  # convert keystore from jks to p12
  $KEYTOOL -importkeystore -srckeystore $sslKeyStore -destkeystore ${sslKeyStore}.p12 \
            -srcstorepass $storePass -deststorepass $storePass -srcalias $CLUSTER_NAME \
            -srcstoretype $storeFormat -deststoretype pkcs12 
  if [ $? -ne 0 ]; then
      echo "Keytool command to create pkcs12 key store failed"
      exit 1
  fi

  # convert keystore from p12 to pem
  openssl pkcs12 -in ${sslKeyStore}.p12 -out ${sslKeyStore}.pem -passin pass:$storePass -passout pass:$storePass
  if [ $? -ne 0 ]; then
      echo "openssl command to create PEM key store failed"
      exit 1
  fi

done

### merge individual truststore into one
echo merging all truststore into one ...
read -r -a node_array <<< "$nodes"
mv $CLUSTER_NAME/${node_array[0]}.$DNS_DOMAIN/ssl_truststore $CLUSTER_NAME/
for node in ${node_array[@]:1}; do
    /opt/mapr/server/manageSSLKeys.sh merge $CLUSTER_NAME/$node.$DNS_DOMAIN/ssl_truststore $CLUSTER_NAME/ssl_truststore
    rm $CLUSTER_NAME/$node.$DNS_DOMAIN/ssl_truststore
done

# convert truststore from jks to p12
$KEYTOOL -importkeystore -srckeystore $CLUSTER_NAME/ssl_truststore -destkeystore $CLUSTER_NAME/ssl_truststore.p12 \
          -srcstorepass $storePass -deststorepass $storePass \
          -srcstoretype $storeFormat -deststoretype pkcs12 
if [ $? -ne 0 ]; then
    echo "Keytool command to create pkcs12 trust store failed"
    exit 1
fi

# convert truststore from p12 to pem
openssl pkcs12 -in $CLUSTER_NAME/ssl_truststore.p12 -out $CLUSTER_NAME/ssl_truststore.pem -passin pass:$storePass -passout pass:$storePass
if [ $? -ne 0 ]; then
    echo "openssl command to create PEM trust store failed"
    exit 1
fi


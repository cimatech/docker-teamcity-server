#!/bin/bash
set -e

mkdir -p $TEAMCITY_DATA_PATH/lib/jdbc $TEAMCITY_DATA_PATH/config
if [ ! -f "$TEAMCITY_DATA_PATH/lib/jdbc/mysql-connector-java-5.1.38-bin.jar" ];
then
    echo "Downloading MySQL JDBC driver..."
    cd /tmp
    wget -q https://dev.mysql.com/get/Downloads/Connector-J/$JDBC_DRIVER.tar.gz
    tar --strip=1 -xz $JDBC_DRIVER/$JDBC_DRIVER-bin.jar -f $JDBC_DRIVER.tar.gz
    mv ./$JDBC_DRIVER-bin.jar $TEAMCITY_DATA_PATH/lib/jdbc/
    rm $JDBC_DRIVER.tar.gz
fi

echo "Reading reverse proxy config"

if [ -n "$PUBLIC_HOST_NAME" ];
then
   echo "Set teamcity public hostname"
   sed -i -e "s/teamcity.public/$PUBLIC_HOST_NAME/" $TEAMCITY_CONF_PATH/server.xml
fi

if [ -n "$REVERSE_PROXY_IP" ];
then
   echo "Set reverse proxy ip address"
   sed -i -e "s/10\\\.0\\\.0\\\.1/$REVERSE_PROXY_IP/" $TEAMCITY_CONF_PATH/server.xml
fi

echo "Booting teamcity server..."
exec /opt/TeamCity/bin/teamcity-server.sh run

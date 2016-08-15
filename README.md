teamcity-docker
===============
Forked from tomatensuppe/teamcity-docker, which is a fork from sjoerdmulder/teamcity  

This container runs a TeamCity server, with a couple of tweaks and configuration variables, particularly for running behind a reverse proxy.  
Comes with the MySql jdbc driver installed.  

Reverse proxy configuration variables:  
- PUBLIC_HOST_NAME: This is the URL you want to hit your build server on
- REVERSE_PROXY_IP: IP address of your reverse proxy server, '.'s must be triple-escaped!

How to run teamcity, behind a reverse proxy and linked to a mysql container:
```
# initialize mariadb container  
docker run --name mymariadb -v mysql_data_dir:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=vewysecrat -e MYSQL_USER=teamcity MYSQL_PASSWORD=vewysecrat -d mariadb:latest  
# create teamcity database and grant permissions  
docker run -it --link mymariadb:mysql --rm mariadb sh -c \  
 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -e "create database teamcity; grant all on teamcity.* to teamcity; grant process on *.* to teamcity"'  
# boot teamcity container  
docker run -d -v teamcity_data_dir:/var/lib/teamcity --name=teamcitysrv \  
   -e PUBLIC_HOST_NAME=buildserver.example.local \  
   -e REVERSE_PROXY_IP="10\\\.10\\\.10\\\.10" \  
   --link mymariadb:mysql -p 8111:8111 shipbeat/teamcity-server
```

  
How to upgrade to a new version?  
You could simply migrate the volumes using the `--volumes-from` option:
```
docker stop OLD_teamcity_server  
docker pull shipbeat/teamcity-server  
docker run -d --volumes-from=OLD_teamcity_server --name=NEW_teamcity_server \  
   -e PUBLIC_HOST_NAME=buildserver.example.local \  
   -e REVERSE_PROXY_IP="10\\\.10\\\.10\\\.10" \  
   --link mymysql:mysql -p 8111:8111 shipbeat/teamcity-server  
```
Notice that you'll have to pass your proxy settings again, since configuration is overwritten by the container upgrade.

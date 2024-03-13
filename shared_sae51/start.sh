#!/bin/bash

docker-compose build
docker-compose up -d

sleep 10

winpty docker-compose exec db mariadb -u dolibarr_user -p dolibarr_db -f init.sql

DB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' shared_sae51-db-1)

docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password -e "CREATE DATABASE IF NOT EXISTS dolibarr_db;"
docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password dolibarr_db < init.sql

docker cp user.csv shared_sae51-db-1:.
docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password dolibarr_db -e "LOAD DATA LOCAL INFILE 'user.csv' INTO TABLE utilisateurs FIELDS TERMINATED BY ',' IGNORE 1 LINES;"

# Configuration automatique des tiers dans Dolibarr

# docker exec -i shared_sae51-web-1 sed -i "s/\('db_server'\s*=>\s*'\).*/\1${DB_IP}',/" ./conf/conf.php
# docker exec -i shared_sae51-web-1 sed -i "s/\('db_name'\s*=>\s*'\).*/\1dolibarr_db',/" ./conf/conf.php
# docker exec -i shared_sae51-web-1 sed -i "s/\('db_user'\s*=>\s*'\).*/\1dolibarr_user',/" ./conf/conf.php
# docker exec -i shared_sae51-web-1 sed -i "s/\('db_pass'\s*=>\s*'\).*/\1dolibarr_password',/" ./conf/conf.php
# docker restart shared_sae51-web-1
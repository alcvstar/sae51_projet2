#!/bin/bash

# Construire les images Docker avec Docker Compose
docker-compose build

# Démarrer les services Docker avec Docker Compose
docker-compose up -d

# Attendre quelques instants pour que les conteneurs démarrent complètement
sleep 10

# Importer les données du fichier CSV dans la base de données MySQL
winpty docker-compose exec db mariadb -u dolibarr_user -p dolibarr_db -f init.sql

# Configuration automatique des tiers dans Dolibarr
# (Vous pouvez inclure ici des commandes pour exécuter des scripts ou des requêtes SQL pour configurer les tiers dans Dolibarr)

# Récupérer l'adresse IP du conteneur du SGBD
DB_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' shared_sae51-db-1)

# Exécuter les commandes SQL pour créer la table des utilisateurs
docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password -e "CREATE DATABASE IF NOT EXISTS dolibarr_db;"
docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password dolibarr_db < init.sql


# Importer les données depuis le fichier CSV dans la base de données
docker cp user.csv shared_sae51-db-1:.
docker exec -i shared_sae51-db-1 mariadb -uroot -proot_password dolibarr_db -e "LOAD DATA LOCAL INFILE 'user.csv' INTO TABLE utilisateurs FIELDS TERMINATED BY ',' IGNORE 1 LINES;"

# Configurer Dolibarr pour utiliser le SGBD
docker exec -i shared_sae51-web-1 sed -i "s/\('db_server'\s*=>\s*'\).*/\1${DB_IP}',/" dolibarr/htdocs/conf/conf.php
docker exec -i shared_sae51-web-1 sed -i "s/\('db_name'\s*=>\s*'\).*/\1dolibarr_db',/" dolibarr/htdocs/conf/conf.php
docker exec -i shared_sae51-web-1 sed -i "s/\('db_user'\s*=>\s*'\).*/\1dolibarr_user',/" dolibarr/htdocs/conf/conf.php
docker exec -i shared_sae51-web-1 sed -i "s/\('db_pass'\s*=>\s*'\).*/\1dolibarr_password',/" dolibarr/htdocs/conf/conf.php

docker exec -it shared_sae51-web-1 ps aux
docker exec -it shared_sae51-web-1 service dolibarr start


# Redémarrer Dolibarr pour appliquer les changements de configuration
docker restart shared_sae51-web-1
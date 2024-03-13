CREATE DATABASE IF NOT EXISTS dolibarr_db;
GRANT ALL PRIVILEGES ON dolibarr_db.* TO 'dolibarr_user'@'%' IDENTIFIED BY 'dolibarr_password';
FLUSH PRIVILEGES;

USE dolibarr_db;

CREATE TABLE IF NOT EXISTS utilisateurs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(255),
    adresse VARCHAR(255),
    telephone VARCHAR(20),
    email VARCHAR(255),
    username VARCHAR(50),
    password VARCHAR(255)
);

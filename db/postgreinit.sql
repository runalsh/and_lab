create database mydb;
create user vagrant with encrypted password 'vagrant';
grant all privileges on database mydb to vagrant;
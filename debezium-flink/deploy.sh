#!/bin/bash
Color_Off='\e[0m'               # Text Reset
Color_WhiteOnBlue='\e[1;44m'    # White text on blue background

printf "${Color_WhiteOnBlue}DOCKER: Stopping existing docker containers${Color_Off}\n"
sudo DEBEZIUM_VERSION=latest docker-compose down

printf "${Color_WhiteOnBlue}DOCKER: Starting docker containers${Color_Off}\n"
sudo DEBEZIUM_VERSION=latest docker-compose up &

until $(curl --output /dev/null --silent --head --fail -H "Accept:application/json" localhost:8083/connectors); do
    printf "${Color_WhiteOnBlue}DOCKER: Waiting for Kafka Connect to come online${Color_Off}\n"
    sleep 5
done

printf "${Color_WhiteOnBlue}POSTGRES: Dropping and creating database and roles${Color_Off}\n"
psql postgresql://postgres:postgres@localhost -f prepare.sql

printf "${Color_WhiteOnBlue}POSTGRES: Restoring from backup${Color_Off}\n"
PGPASSWORD=postgres pg_restore -h localhost -d my_database -U postgres database.backup

printf "${Color_WhiteOnBlue}KAFKA CONNECT: Dropping and creating Debezium Kafka Connector and configuring tables${Color_Off}\n"
curl -i -X DELETE -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/my_debezium_connector
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @debezium.json

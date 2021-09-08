# Description
This package provides a docker environment with everything needed to have a self contained environment for a Postgres->Debezium->Kafka->Flink->Mongo data processing pipeline.

* Kafka components
  * Zookeeper
  * Kafka
  * Kafka Connect
  * Control Center
  * KafDrop
  * KafkaMagic
* Postgres
* Debezium Kafka Connector
* Flink
  * Flink Job Manager
  * Flink Task Manager

This package deploys the containers, restores a postgres backup and connects the debezium connector and creates all the topics for the database tables.

# Getting started
1. Make sure the `3` volume paths defined in the `docker-compose.yml` map correctly to your filesystem. Change if needed.
2. Name your postgres backup `database.backup`.
3. Edit `debezium.json` and add the tables you want Debezium to stream into Kafka topics in the `table.include.list`.
4. Run the `deploy.sh` script to automate all the docker and deployment steps.

# Files
`debezium.json`  
The Debezium configuration that attaches to CDC events to it's specified database tables.

`deploy.sh`
* Drops existing docker containers if already running.
* Deploys all the docker containers.
* Drops database.
* Drops roles.
* Re-creates the roles.
* Imports Postgres backup into the Postgres docker container.
* Deletes existing Debezium Kafka Connector configuration.
* Re-creates the Debezium Kafka Connector configuration and attaches to all the tables to start receiving CDC events.

`docker-compose.yml`  
Contains all the docker configuration for all the requires services.

There are a few docker volumes mapped to local filesystem locations. You may need to adjust the path to fit your system. The following volumes may need to be changed.

Postgres
```
volumes:
     - ~/.local/share/kafka-connect/config:/kafka/config
     - ~/.local/share/kafka-connect/logs:/kafka/logs
```

`prepare.sql`  
This file drops the old database and roles and re-creates them.

`deploy.sh`. 
Run this to automate all the docker+deployment steps to prepare the full docker environment.

# Verify installation

Query Kafka Connect to ensure the Debezium connector is created.
```
curl -H "Accept:application/json" localhost:8083/connectors

["my_debezium_connector"]
```

If the Kafka Connector isn't deployed you'll get a response like the following.
```
[]
```

You should be able to open KafDrop to view the Kafka Topics.
http://localhost:9000/

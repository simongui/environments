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
* MongoDB

# Getting started
Run the `deploy.sh` script to automate all the docker and deployment steps.

# Files
`debezium.json`  
The Debezium configuration that attaches to CDC events to it's specified database tables.

`deploy.sh`  
* Drops TA database.
* Drops roles.
* Re-creates the roles.
* Imports Postgres backup into the Postgres docker container.
* Deletes existing Debezium Kafka Connector configuration.
* Re-creates the Debezium Kafka Connector configuration and attaches to all the qTest tables to start receiving CDC events.

`docker-compose.yml`  
Contains all the docker configuration for all the requires services.

There are a few docker volumes mapped to local filesystem locations. You may need to adjust the path to fit your system. The following volumes may need to be changed.

Postgres
```
volumes:
     - ~/.local/share/kafka-connect/config:/kafka/config
     - ~/.local/share/kafka-connect/logs:/kafka/logs
```

MongoDB
```
volumes:
     - ~/.local/share/mongo:/data/db
```

`prepare.sql`  
This file drops the old database and roles and re-creates them.

`deploy.sh`. 
Run this to automate all the docker+deployment steps to prepare the full docker environment.

# Installation
1. Change the volume paths mentioned above in `docker-compose.yml`
2. `./start.sh`
3. `./deploy.sh`

# Verify installation

Query Kafka Connect to ensure the Debezium connector is created.
```
curl -H "Accept:application/json" localhost:8083/connectors

["tricentis-analytics-connector"]
```

If the Kafka Connector isn't deployed you'll get a response like the following.
```
[]
```

You should be able to open KafDrop to view the Kafka Topics.
http://localhost:9000/

# Orchestrating Generic Data Module (GDM) and Liquibase with Docker
falko.gloeckler@mfn-berlin.de   
  

## Purpose
* Deployment of the Generic Data Module (GDM) with Docker
* For versioning the data model an additional Docker container for Liquibase (http://liquibase.org) is set up
* The GDM container runs in daemon mode
* The Liquibase container will only run temporarily for database updates

## Requirements
* Unix operating system (because not yet tested on Windows machines)
* latest Docker engine intstallation 
* MySQL or Postgres database accessible for the GDM

## Usage
### Installation
```sh
# build the Docker images, initiate the database with Liquibase and then start the GDM as daemon
   make install DB_HOST="<your db hostname or IP>" DB_USER="<db user>" DB_NAME="<db schema name>" GDM_NAME="<docker container name for GDM>" GDM_CONFIG_PATH="<path to GDM config dir>" CHANGELOGS="<liquibase local changelogs>"
  ```
  
### Roll-out another GDM instance
```sh
# build the Docker images, initiate the database with Liquibase and then start the GDM as daemon
   make gdm-init DB_HOST="<your db hostname or IP>" DB_USER="<db user>" DB_NAME="<db schema name>" GDM_NAME="<docker container name for GDM>" GDM_PORT=<port for the GDM webapp> GDM_CONFIG_PATH="<path to GDM config dir>" CHANGELOGS="<liquibase local changelogs>"
  ```

### Data model update
```sh
# run Liquibase to populate any changes of the data model
   make db-update DB_HOST="<your db hostname or IP>" DB_USER="<db user>" DB_NAME="<db schema name>" GDM_NAME="<docker container name for GDM>" GDM_PORT=<port for the webapp> CHANGELOGS="<liquibase local changelogs>"
```

### Service Controlling
```sh
# Start the GDM service 
   make start GDM_NAME="<docker container name for GDM>" 

# Stop the GDM service 
   make stop GDM_NAME="<docker container name for GDM>" 

# Restart the GDM service 
   make restart GDM_NAME="<docker container name for GDM>" 
```

### Uninstallation
(@TODO)

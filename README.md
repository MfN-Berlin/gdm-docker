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
   make install CHANGELOGS="<your local changelogs>"
```

### Data model update
```sh
# run Liquibase to populate any changes of the data model
   make db-update CHANGELOGS="<your local changelogs>"
```

### Service Controlling
```sh
# Start the GDM service 
   make start

# Stop the GDM service 
   make stop

# Restart the GDM service 
   make restart
```

### Uninstallation
(@TODO)

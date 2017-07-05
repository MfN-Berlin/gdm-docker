#!make

# set default values if variable not passed as argument
PWD ?= 
$(eval PWD := $(shell pwd))
CHANGELOGS ?= $(value PWD)/liquibase/changelogs
GDM_PORT ?= 80
GDM_DATE ?= 
$(eval GDM_DATE := $(shell date "+%Y%m%d"))
GDM_NAME ?= gdm_$(value GDM_DATE)
$(eval GDM_CONFIG_PATH := $(value PWD)/gdm/)

ifndef DB_PASSWORD
$(eval DB_PASSWORD ?= $(shell bash -c 'read -s -p "Please enter the database password: " pwd; echo $$pwd'))
endif

ifndef DEBUG
DEBUG := info
endif

DB_HOST ?= 
DB_PORT ?= 
DB_USER ?=
DB_NAME ?=

all: help

help:
	@echo Usage: 
	# TODO provide short documentation
	@echo "		make install"
	@echo "		make update"
	
install: 
	# prompt for password
#	@bash -c 'read -r -p "Please enter the database password: " passwd; export passwd'
	
	# build Liquibase Docker image
	docker build --rm --tag=liquibase:latest ./liquibase/
	
	# populate changelogs
	make db-update-test DB_PASSWORD=$(value DB_PASSWORD)
	
	# build GDM Docker image
	docker build --rm --tag=gdm:latest ./gdm/
	
	# run GDM Docker container
	make gdm-init GDM_NAME=$(GDM_NAME) GDM_CONFIG_PATH=$(GDM_CONFIG_PATH) DB_PASSWORD=$(value DB_PASSWORD)

	
db-update:
	make db-check DB_PASSWORD=$(value DB_PASSWORD)
	
	@echo Run Liquibase for updating database from $(CHANGELOGS)
	docker run --rm -it --volume=$(CHANGELOGS):/opt/liquibase/changelogs liquibase:latest --changeLogFile="/opt/liquibase/changelog.xml" --logLevel=$(value DEBUG) --username="$(DB_USER)" --password="$(value DB_PASSWORD)" --url="jdbc:mysql://$(DB_HOST)/$(DB_NAME)?useSSL=false" migrate
	
	# update the GDM's UI
	docker exec -it $(GDM_NAME) bash -c 'cd $$GDM_HOME/lib/tools && php make_ui.php'
	
db-update-test:
	make db-check DB_PASSWORD=$(value DB_PASSWORD)
	
	@echo Run Liquibase for updating database from $(CHANGELOGS)
	docker run --rm -it --volume=$(CHANGELOGS):/opt/liquibase/changelogs liquibase:latest --changeLogFile="/opt/liquibase/changelog.xml" --logLevel=$(value DEBUG) --username="$(DB_USER)" --password="$(value DB_PASSWORD)" --url="jdbc:mysql://$(DB_HOST)/$(DB_NAME)?useSSL=false" updateSQL
	
	
db-check:
# check variables
ifeq ($(strip $(DB_PORT)),)
DB_PORT := 3306
endif

ifeq ($(strip $(DB_HOST)),)
   $(error DB_HOST undefined!)
endif

ifeq ($(strip $(DB_NAME)),)
   $(error DB_NAME undefined!)
endif

ifeq ($(strip $(DB_USER)),)
   $(error DB_USER undefined!)
endif
	
gdm-init:
	make db-check
	
	# run GDM Docker container as deamon
	docker run -d -p$(value GDM_PORT):80 --restart=always -v $(value GDM_CONFIG_PATH)/:/usr/share/app/custom --name=$(value GDM_NAME) --hostname=$(value GDM_NAME) --env "DB_NAME=$(value DB_NAME)" --env="DB_HOST=$(value DB_HOST)" --env="DB_PORT=$(value DB_PORT)" --env="DB_HOST=$(value DB_HOST)" --env="DB_USER=$(value DB_USER)" gdm
	
	make db-update DB_PASSWORD=$(value DB_PASSWORD)
	
start:
	docker start $(GDM_NAME)
	
stop:
	docker stop $(GDM_NAME)
	
restart:
	docker restart $(GDM_NAME)
	
	

#!make
$(eval GDM_CONFIG_PATH := $(value PWD)/gdm/custom)
ifeq ($(strip $(GDM_CONFIG_PATH)),)
   $(error Parameter GDM_CONFIG_PATH is undefined!)
endif
include $(GDM_CONFIG_PATH)/.env

# set default values if variable not passed as argument
PWD ?= 
$(eval PWD := $(shell pwd))
CHANGELOGS ?= $(value GDM_CONFIG_PATH)/liquibase/changelogs
GDM_PORT ?= 80
GDM_DATE ?= 
$(eval GDM_DATE := $(shell date "+%Y%m%d"))
GDM_NAME ?= gdm_$(value GDM_DATE)

ifndef DB_PASSWORD
$(eval DB_PASSWORD ?= $(shell bash -c 'read -s -p "Please enter the database password: " pwd; echo $$pwd'))
endif

ifndef DEBUG
DEBUG := info
endif

DB_HOST ?= 
DB_PORT ?= 
DB_USERNAME ?=
DB_DATABASE ?=
DB_DATABASE ?= $(value DB_DATABASE) 
SKIP_LIQUIBASE ?=

all: help

help:
	@echo Usage: 
	# TODO provide short documentation
	@echo "		make install"
	@echo "		make db-update-test"
	@echo "		make db-update"
	
install: 
	# prompt for password
#	@bash -c 'read -r -p "Please enter the database password: " passwd; export passwd'
	
	# build Liquibase Docker image
	docker build --rm --tag=liquibase:latest ./liquibase/
	
	# populate changelogs
	if [ -z $(value SKIP_LIQUIBASE) ]; then make db-update-test DB_PASSWORD=$(value DB_PASSWORD); fi
	
	# build GDM Docker image
	docker build --rm --tag=gdm:latest ./gdm/
	
	# run GDM Docker container
	make gdm-init GDM_NAME=$(GDM_NAME) GDM_CONFIG_PATH=$(GDM_CONFIG_PATH) DB_PASSWORD=$(value DB_PASSWORD) SKIP_LIQUIBASE=$(value SKIP_LIQUIBASE)

	
db-update:
	make db-check DB_PASSWORD=$(value DB_PASSWORD) SKIP_LIQUIBASE=$(value SKIP_LIQUIBASE)
	
	if [ -z $(value SKIP_LIQUIBASE) ]; then echo Run Liquibase for updating database from $(CHANGELOGS) && \
		docker run --rm -it --volume=$(CHANGELOGS):/opt/liquibase/changelogs liquibase:latest --changeLogFile="/opt/liquibase/changelog.xml" --logLevel=$(value DEBUG) --username="$(DB_USERNAME)" --password="$(value DB_PASSWORD)" --url="jdbc:mysql://$(DB_HOST)/$(DB_DATABASE)?useSSL=false" migrate; fi
	
	# update the GDM's UI
	make gdm-rebuild-ui GDM_NAME=$(GDM_NAME) GDM_CONFIG_PATH=$(GDM_CONFIG_PATH) SKIP_LIQUIBASE=$(value SKIP_LIQUIBASE) 
	
db-update-test:
	make db-check DB_PASSWORD=$(value DB_PASSWORD) SKIP_LIQUIBASE=$(value SKIP_LIQUIBASE)
	
	@echo Run Liquibase for updating database from $(CHANGELOGS)
	docker run --rm -it --volume=$(CHANGELOGS):/opt/liquibase/changelogs liquibase:latest --changeLogFile="/opt/liquibase/changelog.xml" --logLevel=$(value DEBUG) --username="$(DB_USERNAME)" --password="$(value DB_PASSWORD)" --url="jdbc:mysql://$(DB_HOST)/$(DB_DATABASE)?useSSL=false" updateSQL
	
	
db-check:
# check variables
 ifeq ($(strip $(DB_PORT)),)
 DB_PORT := 3306
 endif

 ifeq ($(strip $(DB_HOST)),)
   $(error DB_HOST undefined!)
 endif

 ifeq ($(strip $(DB_DATABASE)),)
   $(error DB_DATABASE undefined!)
 endif

 ifeq ($(strip $(DB_USERNAME)),)
   $(error DB_USERNAME undefined!)
 endif
	# @echo Database check OK!
	
	
gdm-init:
	if [ -z $(value SKIP_LIQUIBASE) ]; then make db-check DB_PASSWORD=$(value DB_PASSWORD); fi
	
	# run GDM Docker container as deamon
	docker run -d -p$(value GDM_PORT):80 --restart=always -v $(value GDM_CONFIG_PATH)/:/usr/share/gdm/custom --name=$(value GDM_NAME) --hostname=$(value GDM_NAME) --env "DB_DATABASE=$(value DB_DATABASE)" --env="DB_HOST=$(value DB_HOST)" --env="DB_PORT=$(value DB_PORT)" --env="DB_HOST=$(value DB_HOST)" --env="DB_USERNAME=$(value DB_USERNAME)" gdm
	
	# Create the tables needed by GDM
	docker exec -i $(value GDM_NAME) bash -c 'php artisan migrate'
		
	make db-update DB_PASSWORD=$(value DB_PASSWORD) SKIP_LIQUIBASE=$(value SKIP_LIQUIBASE)
	
	docker exec -it $(value GDM_NAME) bash -c '  \
			composer dump-autoload && \
			php artisan db:seed  \
		'
	
gdm-rebuild-ui:
	docker exec -it $(value GDM_NAME) bash -c '  \
			cd lib/tools && \
			php make_ui.php  \
		'

	# create API docs
	docker exec -it $(value GDM_NAME) bash -c '  \
			php artisan vendor:publish --tag=public && \
			php artisan vendor:publish --tag=config && \
			php artisan vendor:publish --tag=views \
		'


	
start:
	docker start $(GDM_NAME)
	
stop:
	docker stop $(GDM_NAME)
	
restart:
	

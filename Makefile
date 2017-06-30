#!make

# set default values if variable not passed as argument
PWD = $(shell pwd)
CHANGELOGS ?= $(value PWD)/liquibase/changelogs.xml
GDM_PORT ?= 80
GDM_DATE ?= 
$(eval GDM_DATE := $(shell date "+%Y%m%d"))
GDM_TIME ?= 
$(eval GDM_TIME := $(shell date "+%Y%m%d%T%N"))
GDM_NAME ?= gdm_$(value GDM_DATE)
$(eval GDM_CONFIG_PATH := $(value PWD)/gdm/)

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
	make db-update
	
	# build GDM Docker image
	docker build --rm --tag=gdm:latest ./gdm/
	
	# run GDM Docker container
	make gdm-init GDM_NAME=$(GDM_NAME) GDM_CONFIG_PATH=$(GDM_CONFIG_PATH) DB_PASSWORD=$(DB_PASSWORD)

	
db-update:
	@echo @TODO: run liquibase update from $(CHANGELOGS)
	# docker run -it --volume=$(CHANGELOGS):/changelogs liquibase:latest
	
	
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

ifndef DB_PASSWORD
   # Set the timestamp as kind of hash value in order to allow comparisons needed for conditionally prompting for manually password entry.
   DB_PASSWORD_CHECK:=$(value GDM_TIME)
else
   DB_PASSWORD_CHECK:=
endif
	
gdm-init:
	make db-check
	
	# run GDM Docker container as deamon
	docker run -d -p$(value GDM_PORT):80 --restart=always -v $(value GDM_CONFIG_PATH)/:/usr/share/app/custom --name=$(value GDM_NAME) --hostname=$(value GDM_NAME) --env "DB_NAME=$(value DB_NAME)" --env="DB_HOST=$(value DB_HOST)" --env="DB_PORT=$(value DB_PORT)" --env="DB_HOST=$(value DB_HOST)" --env="DB_USER=$(value DB_USER)" --env="DB_PASSWORD=$(if $(filter %$(value GDM_TIME),$(value DB_PASSWORD_CHECK)),$(shell bash -c 'read -s -p "Please enter the database password: " pwd; echo $$pwd'),$(value DB_PASSWORD))" gdm
	
start:
	docker start $(GDM_NAME)
	
stop:
	docker stop $(GDM_NAME)
	
restart:
	docker restart $(GDM_NAME)
	
	

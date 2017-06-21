#!make

PWD = $(shell pwd)
CHANGELOGS = $(CHANGELOGS)
GDM_PORT = $(GDM_PORT)
GDM_NAME = $(GDM_NAME)
GDM_CONFIG_PATH = $(CONFIG_PATH)

all:
	@echo Usage: 
	# TODO provide short documentation
	@echo "		make install"
	@echo "		make update"
	

install: 
	# build Liquibase Docker image
	docker build --rm --tag=liquibase:latest ./liquibase/
	
	# populate changelogs
	make db-update 
	
	# build GDM Docker image
	docker build --rm --tag=gdm:latest ./gdm/
	
	# run GDM Docker container
	make gdm-init
	

db-update:
	@echo @TODO: run liquibase update from $(CHANGELOGS)
	# docker run -it --volume=$(CHANGELOGS):/changelogs liquibase:latest
	
	
gdm-init:
	docker run -d -p$(GDM_PORT):80 --restart=always -v $(GDM_CONFIG_PATH)/.env:/usr/share/app/.env --name=$(GDM_NAME) --hostname=$(GDM_NAME) --env "DB_NAME=$(DB_NAME)" --env "DB_HOST=$(DB_HOST)" --env "DB_PORT=$(DB_PORT)" --env "DB_HOST=$(DB_HOST)" --env "DB_USER=$(DB_USER)" --env "DB_PASSWORD=$(DB_PASSWORD)" gdm
	
	
start:
	docker start $(GDM_NAME)
	
stop:
	docker stop $(GDM_NAME)
	
restart:
	docker restart $(GDM_NAME)
	

	

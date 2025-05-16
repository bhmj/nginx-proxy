SHELL := /bin/bash

define USAGE

Usage: make <target>

some of the <targets> are:

  setup            - create required dirs
  run              - run Nginx proxy
  stop             - stop Nginx proxy

The project creates and uses \033[1;33m/var/nginx-proxy/\033[0m dir on host machine.
Please be aware that it will be written to by multiple external projects.

endef
export USAGE

define CAKE
   \033[1;31m. . .\033[0m
   i i i
  %~%~%~%
  |||||||
-=========-
endef
export CAKE

help:
	printf "%b\n" "$$USAGE"

setup:
	sudo mkdir -p /var/nginx-proxy/configs
	sudo mkdir -p /var/nginx-proxy/static
	sudo chmod 777 /var/nginx-proxy/configs
	sudo chmod 777 /var/nginx-proxy/static
	touch .env

run:
	docker compose -f docker-compose.yaml up -d

stop:
	docker compose -f docker-compose.yaml down

cake:
	printf "%b\n" "$$CAKE"

$(V).SILENT:

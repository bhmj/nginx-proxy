SHELL := /bin/bash

define USAGE
NGINX proxy with dynamic config and certs support. Runs multiple servers at a single machine/IP.

Usage: make <target>

some of the <targets> are:

  setup               - create required dirs
  cleanup             - cleanup config dir, must reinit running services
  dev-up, dev-down    - run in dev mode
  prod-up, prod-down  - run in prod mode
  cert                - generate self-signed cert for the domain (interactive)

The project creates and uses \033[1;33m/var/nginx-proxy/\033[0m dir on host machine.
Please be aware that it will be written to by multiple external projects.

Production vs development:

                      | \033[1;33mdev\033[0m                | \033[1;33mprod\033[0m
----------------------+--------------------+--------------------
 certbot container    | no                 | yes
 certs location       | ./certs/{domain}/  | "certs" volume

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
	./scripts/setup.sh

cleanup:
	rm -rf /var/nginx-proxy/configs/*

dev-up:
	./scripts/reconnect-networks.sh
	docker compose -f docker-compose.dev.yaml up -d

dev-down:
	docker compose -f docker-compose.dev.yaml down

prod-up:
	./scripts/reconnect-networks.sh
	docker compose -f docker-compose.prod.yaml up -d

prod-down:
	docker compose -f docker-compose.prod.yaml down

cert:
	./scripts/make-cert.sh

cake:
	printf "%b\n" "$$CAKE"

$(V).SILENT:

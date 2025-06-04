SHELL := /bin/bash

define USAGE
NGINX proxy with dynamic config and certs support. Runs multiple servers at a single machine/IP.

Usage: make <target>

some of the <targets> are:

  setup               - create required dirs
  cleanup             - cleanup config dir
  dev-up, dev-down    - run in dev mode
  prod-up, prod-down  - run in prod mode
  cert                - generate self-signed cert for the domain (interactive)

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
	> /var/nginx-proxy/networks

dev-up:
	./scripts/stash.sh
	docker compose -f docker-compose.dev.yaml up -d
	./scripts/stash-pop.sh

dev-down:
	docker compose -f docker-compose.dev.yaml down

prod-up:
	./scripts/stash.sh
	docker compose -f docker-compose.prod.yaml up -d
	./scripts/stash-pop.sh

prod-down:
	docker compose -f docker-compose.prod.yaml down

cert:
	./scripts/make-cert.sh

cake:
	printf "%b\n" "$$CAKE"

$(V).SILENT:

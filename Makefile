SHELL := /bin/bash

define USAGE
NGINX proxy with dynamic config and certs support. Runs multiple servers at a single machine/IP.

Usage: make <target>

some of the <targets> are:

  setup               - create required dirs
  cleanup             - cleanup config dir
  dev-up, prod-up     - run in dev/prod mode
  down                - stop dev/prod
  cert                - generate a wildcard cert for the domain (interactive)
  reconnect           - reconnect all previously-registered projects' networks
                        (only needed if the container restarted outside of
                        dev-up/prod-up, e.g. after a crash - see README)

  dev
   - runs with local ./certs (mkcert)
   - uses .env_dev
   - no certbot
   - unregistered domains get a dev-only self-signed 404 fallback instead of a connection error

  prod
   - runs with `certs` volume
   - uses .env_prod
   - runs certbot with `certs` volume

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
	mkdir -p ./certs/_default
	[ -f ./certs/_default/fullchain.pem ] || openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
		-keyout ./certs/_default/privkey.pem -out ./certs/_default/fullchain.pem -subj "/CN=nginx-proxy-default"
	./scripts/stash.sh
	cp -f scripts/default.dev.conf /var/nginx-proxy/configs/default.conf
	docker compose -f docker-compose.dev.yaml up -d
	./scripts/stash-pop.sh

prod-up:
	./scripts/stash.sh
	cp -f scripts/default.conf /var/nginx-proxy/configs/
	docker compose -f docker-compose.prod.yaml up -d
	./scripts/stash-pop.sh

down:
	docker compose -f docker-compose.dev.yaml down
	docker compose -f docker-compose.prod.yaml down

cert:
	./scripts/make-cert.sh

reconnect:
	./scripts/reconnect-networks.sh

cake:
	printf "%b\n" "$$CAKE"

$(V).SILENT:

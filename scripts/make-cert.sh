#!/bin/bash

set -e

USAGE="
This generates a locally-trusted self-signed cert for your domain AND a
wildcard for its subdomains.
The result will be saved in ./certs/{domain}/

Usage:
  make cert DOMAIN=mydomain.com
"

if [ -z "$DOMAIN" ] && [ -z "$1" ]; then
  printf "$USAGE"
  read -p "Please enter the base domain name (like mydomain.com) : " DOMAIN
else
  [ -z "$DOMAIN" ] && DOMAIN=$1
fi

WILDCARD="*.$DOMAIN"

mkdir -p ./certs/${DOMAIN}
mkcert -cert-file ./certs/${DOMAIN}/fullchain.pem -key-file ./certs/${DOMAIN}/privkey.pem ${DOMAIN} ${WILDCARD}

printf "\nALL DONE\n\nCert covers: ${DOMAIN} ${WILDCARD}\n\nAdd one /etc/hosts line per subdomain you actually use, e.g.:\n  127.0.0.1 ${DOMAIN}\n  127.0.0.1 cache.${DOMAIN}\n\nAny project's nginx conf can reference this same cert regardless of its own\nserver_name, since it's a wildcard:\n  ssl_certificate     /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;\n  ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;\n\n"

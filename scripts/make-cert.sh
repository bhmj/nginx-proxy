#!/bin/bash

set -e

USAGE="
This generates a self-signed cert for your domain.
The result will be saved in ./certs/{domain}/
"

if [ -z "$DOMAIN" ] && [ -z "$1" ]; then
  printf "$USAGE"
  read -p "Please enter the domain name (like mydomain.com) : " DOMAIN
else
  [ -z "$DOMAIN" ] && DOMAIN=$1
fi

mkdir -p ./certs/${DOMAIN}
# openssl genrsa -out ./certs/${DOMAIN}/privkey.pem 2048
# openssl req -new -key ./certs/${DOMAIN}/privkey.pem -out ./certs/${DOMAIN}/request.csr -subj "/CN=${DOMAIN}"
# openssl x509 -req -days 365 -in ./certs/${DOMAIN}/request.csr -signkey ./certs/${DOMAIN}/privkey.pem -out ./certs/${DOMAIN}/fullchain.pem
mkcert -cert-file ./certs/${DOMAIN}/fullchain.pem -key-file ./certs/${DOMAIN}/privkey.pem ${DOMAIN}

printf "\nALL DONE\n\nDon't forget to add '127.0.0.1 ${DOMAIN}' line in your /etc/hosts\n\n"

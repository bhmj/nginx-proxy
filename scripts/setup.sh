#!/bin/bash

touch .env_dev
touch .env_prod
sudo mkdir -p /var/nginx-proxy/configs
sudo mkdir -p /var/nginx-proxy/domains
sudo touch /var/nginx-proxy/networks
USER=`whoami`
GROUP=`id -gn`
sudo chown $USER:$GROUP /var/nginx-proxy/configs
sudo chown $USER:$GROUP /var/nginx-proxy/domains
sudo chown $USER:$GROUP /var/nginx-proxy/networks

if [[ $OSTYPE == 'darwin'* ]]; then
    brew install mkcert
else
    # sorry, non-debian guys
    sudo apt install mkcert
fi

# Fixed fallback cert for the dev-only default_server 443 block.
if [[ ! -f ./certs/_default/fullchain.pem ]]; then
    mkdir -p ./certs/_default
    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
        -keyout ./certs/_default/privkey.pem \
        -out ./certs/_default/fullchain.pem \
        -subj "/CN=nginx-proxy-default"
fi

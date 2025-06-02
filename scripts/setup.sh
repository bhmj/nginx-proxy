#!/bin/bash

touch .env_dev
touch .env_prod
sudo mkdir -p /var/nginx-proxy/configs
sudo mkdir -p /var/nginx-proxy/static
sudo touch /var/nginx-proxy/networks
USER=`whoami`
GROUP=`id -gn`
sudo chown $USER:$GROUP /var/nginx-proxy/configs
sudo chown $USER:$GROUP /var/nginx-proxy/static
sudo chown $USER:$GROUP /var/nginx-proxy/networks

if [[ $OSTYPE == 'darwin'* ]]; then
    brew install mkcert
else
    # sorry, non-debian guys
    sudo apt install mkcert
fi

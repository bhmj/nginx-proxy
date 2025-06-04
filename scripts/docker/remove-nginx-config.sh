#!/bin/bash

NAMESPACE=$1 # like "dosasm"
CONF_MASK=$2 # like "docker-assets/prod/nginx/*.*"

if [[ -z ${CONF_MASK} ]]; then
  printf "Disconnects a project from nginx-proxy.\nUsage: $0 {namespace} {conf-mask}\n\n  {namespace} is a docker-compose namespace, part of net name. Can be empty string.\n  {conf-mask} is a path to nginx config(s), can be a mask\n"
  exit 1
fi

if [[ -n ${NAMESPACE} ]]; then
  cat /var/nginx-proxy/networks | grep -v ${NAMESPACE} > /tmp/nginx-networks || true
  cat /tmp/nginx-networks > /var/nginx-proxy/networks
  docker network disconnect ${NAMESPACE}_net nginx-proxy
fi

for CONF in $CONF_MASK; do
  if [[ -f "$CONF" ]]; then
    CONF_BASENAME=$(basename "$CONF")
    rm /var/nginx-proxy/configs/${CONF_BASENAME}
  fi
done

docker exec nginx-proxy nginx -s reload

#!/bin/bash

NAMESPACE=$1 # like "dosasm"
CONF_MASK=$2 # like "docker-assets/prod/nginx/*.*"

if [ -z "${CONF_MASK}" ] || [ -z "${NAMESPACE}" ]; then
  printf "Connects a project to nginx-proxy.\nUsage: $0 {namespace} {conf-mask}\n\n  {namespace} is a docker-compose namespace, part of net name\n  {conf-mask} is a path to nginx config(s), can be a mask\n"
  exit 1
fi

docker network connect ${NAMESPACE}_net nginx-proxy
echo ${NAMESPACE} >> /var/nginx-proxy/networks

for CONF in ${CONF_MASK}; do
  if [[ -f "$CONF" ]]; then
    export_vars=$(grep -oE '\$\{[A-Z0-9_]+\}' "$CONF" | sort -u | tr '\n' ' ') # list env vars referenced in file
    CONF_BASENAME=$(basename "${CONF}")
    envsubst "$export_vars" < "${CONF}" > /var/nginx-proxy/configs/${CONF_BASENAME}
  else
    echo "Skipping '${CONF}' : not a regular file."
  fi
done

docker exec nginx-proxy nginx -s reload

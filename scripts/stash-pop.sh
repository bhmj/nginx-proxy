#!/bin/bash

mv /tmp/nginx-proxy/configs/* /var/nginx-proxy/configs/

# restore network attachments

NAMESPACES=/var/nginx-proxy/networks

# file not exists
[[ ! -f "${NAMESPACES}" ]] && exit
# file contains no entries
grep -q '[^[:space:]]' "$NAMESPACES" || exit

# Read networks and connect nginx-proxy to each
while IFS= read -r network; do
  [[ -z "$network" ]] && continue

  set -x
  docker network connect "${network}_net" nginx-proxy
  { set +x; } 2>/dev/null
done < "${NAMESPACES}"

docker exec nginx-proxy nginx -s reload
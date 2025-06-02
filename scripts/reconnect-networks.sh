#!/bin/bash

NAMESPACES=/var/nginx-proxy/networks

[[ ! -f "${NAMESPACES}" ]] && exit

# Read each line (network name) and run docker command
while IFS= read -r network; do
  [[ -z "$network" ]] && continue

  docker network connect "${network}_net" nginx-proxy
done < "${NAMESPACES}"

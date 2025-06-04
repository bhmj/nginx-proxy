#!/bin/bash
DOMAIN=dummy.com

echo "Please make sure you've added '127.0.0.1 ${DOMAIN}' line to your /etc/hosts before running this"
echo "Press Ctrl+C to exit or Enter to continue"
read
set -e
pwd | grep example > /dev/null && cd ..
make cert DOMAIN=${DOMAIN}
make dev-up
mkdir -p /var/nginx-proxy/static/${DOMAIN}/
cp -r example/www/. /var/nginx-proxy/static/${DOMAIN}/
docker exec nginx-proxy cat /app/scripts/install-nginx-config.sh | bash -s -- "" example/dummy.conf
[[ "$OSTYPE" == "darwin"* ]] && open https://dummy.com
[[ "$OSTYPE" != "darwin"* ]] && xdg-open https://dummy.com
echo "Press Enter to stop the server..."
read
docker exec nginx-proxy cat /app/scripts/remove-nginx-config.sh | bash -s -- "" example/dummy.conf

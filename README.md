## Path mapping

Local host path `/var/nginx-proxy/configs` is mapped into Nginx container as `/etc/nginx/conf.d`.  
Put the project config into `/var/nginx-proxy/configs` and run `docker exec nginx-proxy nginx -s reload`.

Local host path `/var/nginx-proxy/static` is mapped into Nginx container as `/var/www/static`.
Copy static data for the project into `/var/nginx-proxy/static/<project_name>/` and it is ready to use.

## Usage

### Dev mode: 

Certs are generated, domain is substituted using '/etc/hosts'.

`make cert`      - (interactive) create self-signed cert for "local" domain.  
`make dev-up`    - run the proxy.  
`make dev-down`  - stop the proxy.  

### Prod mode: 

Certs are handled by certbot, domain is assigned using DNS.  

`make prod-up`    - run the proxy.  
`make prod-down`  - stop the proxy.

### Install/remove config

To install a config for the new server, start the proxy then run  
`docker exec nginx-proxy cat /app/scripts/install-nginx-config.sh | bash -s -- {conf-mask} {namespace}`

## Structure

<my_project>
    assets/
        nginx.conf
            - in simplest case just put in `/var/nginx-proxy/configs/`
            - you may want to enrich it with env vars, use `envsubst`
            - reload nginx config after update: `docker exec nginx-proxy nginx -s reload`
    www/
        static/
            js/
                script.js
            images/
                image.png
            - copy to `/var/nginx-proxy/static/<my_project>/` to get `/var/nginx-proxy/static/<my_project>/js`, `/var/nginx-proxy/static/<my_project>/images` etc
        dynamic/
            - do not serve dynamic content; use volumes instead.
            
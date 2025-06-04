# Nginx-proxy: Docker HTTP(S) multiserver

## What is it?

This is a Docker-compose Nginx server setup which simplifies multiple web server deployment.  

## More details

It runs Nginx with predefined environment and ready-to-use scripts.  
In order to add new web server you need:
  - run the Nginx-proxy (`make dev-up`)
  - write an nginx conf file for your server
  - generate SSL certificate (`make cert`)
  - run your backend or prepare static files
  - install your nginx conf file to Nginx-proxy:  
  `docker exec nginx-proxy cat /app/scripts/install-nginx-config.sh | bash -s -- {namespace} {your-nginx-config.conf}`

## Initial setup

Run `make setup` to create required dirs and install required tools (**mkcert**).

The project creates and uses **/var/nginx-proxy/** dir on host machine. Please be aware that it will be written to by multiple external projects.

## Path mapping

Local host path `/var/nginx-proxy/configs` is mapped into Nginx container as `/etc/nginx/conf.d`.  
Put the project config into `/var/nginx-proxy/configs` and run `docker exec nginx-proxy nginx -s reload`. The script `install-nginx-config.sh` does it for your convenience.

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

### Production vs development

|   | dev | prod
|---|---|---
| domain in /etc/hosts | yes | no
| certbot container | no | yes
| certs location | ./certs/{domain}/ | "certs" volume

### Install/remove config

To install a config for the new server, start the proxy then run  
`docker exec nginx-proxy cat /app/scripts/install-nginx-config.sh | bash -s -- {namespace} {conf-mask}`

To remove a config for the server, run  
`docker exec nginx-proxy cat /app/scripts/remove-nginx-config.sh | bash -s -- {namespace} {conf-mask}`

`{namespace}` here is a docker-compose namespace of the backend running. It is used to add the nginx-proxy into the backend network. In case you don't use docker-compose just pass the empty string "".

### The simplest case (static, with SSL)

1. Add `127.0.0.1 dummy.com` to your **/etc/hosts**
2. Run `./example/run-local-dummy.com-server.sh`

## Sample webserver project structure

```
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
```
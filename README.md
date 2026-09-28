# Nginx-proxy: Docker HTTP(S) multiserver

## What is it?

This is a Docker-compose Nginx server setup which simplifies multiple web server deployment.  

## Details

It runs Nginx with predefined environment and ready-to-use scripts.  
In order to add new web server you need:
  - run the Nginx-proxy (`make dev-up` or `make prod-up`)
  - generate a cert for your base domain (`make cert DOMAIN=yourdomain.com`) -
    this is a **wildcard** cert (`yourdomain.com` + `*.yourdomain.com`)
  - write an nginx conf file for your server
  - run your backend or prepare static files
  - install your nginx conf file to Nginx-proxy:  
  `docker exec nginx-proxy cat /app/scripts/install-nginx-config.sh | bash -s -- {namespace} {your-nginx-config.conf}`

## Initial setup

Run `make setup` to create required dirs and install required tools (**mkcert**).

The project creates and uses **/var/nginx-proxy/** dir on host machine. Please be aware that it will be written to by multiple external projects.

## Path mapping

Local host path `/var/nginx-proxy/configs` is mapped into Nginx container as `/etc/nginx/conf.d`.  
Put the project config into `/var/nginx-proxy/configs` and run `docker exec nginx-proxy nginx -s reload`. The script `install-nginx-config.sh` does it for your convenience.

Local host path `/var/nginx-proxy/domains` is mapped into Nginx container as `/var/www`.
Copy static data for the project into `/var/nginx-proxy/domains/{project_domain_name}/` and it is ready to use.

**This is a copy, not a live mount** - fine for build output or anything
that doesn't change while you're working (this is what combobox's prod
`copy_static` uses), but editing your source afterward won't show up until
you copy again. For anything you're actively editing during dev, don't use
this path at all: run your own tiny static server (e.g. `nginx:alpine`)
inside your own project's compose, bind-mount your real source directory
into *that* container, and `proxy_pass` to it from the conf fragment you
register here instead. Same end result in the browser, but the mount stays
inside the repo you actually control and edits show up immediately.

## Usage

### Dev mode: 

Certs are generated (mkcert, wildcard per base domain), domain is substituted using '/etc/hosts'.

`make cert DOMAIN=x.com`  - (interactive if DOMAIN omitted) create a wildcard cert for `x.com` + `*.x.com`.  
`make dev-up`             - run the proxy.
`make down`               - stop the proxy (dev or prod, whichever is running).

### Prod mode: 

Certs are handled by certbot, domain is assigned using DNS.

`make prod-up`  - run the proxy.  
`make down`     - stop the proxy.

### Production vs development

|   | dev | prod
|---|---|---
| domain in /etc/hosts | yes | no
| certbot container | no | yes
| certs location | ./certs/{domain}/ | "certs" volume
| unregistered domain | 404 (dev-only fallback cert) | connection error/TLS failure

### Recovering from an unexpected restart

`stash.sh`/`stash-pop.sh` preserve every registered project's config and
network attachment across a `make dev-up`/`prod-up` you run yourself. If the
container instead gets recreated some other way (crash + Docker's
`restart: always`, a manual `docker rm`, a host reboot without re-running
`make dev-up`), previously-registered projects' Docker network attachments
won't automatically reconnect - their config files are still there (host
bind mount), but nginx-proxy won't be able to reach anything that was
reached via a `{namespace}_net` connection until you run:

`make reconnect` - reconnects every namespace recorded in `/var/nginx-proxy/networks` and reloads nginx.

(Projects registered with an empty namespace, i.e. reached via
`host.docker.internal` rather than a docker network join, aren't affected by
this at all.)

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
            - copy to `/var/nginx-proxy/domains/<your-domain>/` to get `/var/nginx-proxy/domains/<your-domain>/js`, `/var/nginx-proxy/domains/<your-domain>/images` etc - only for content that doesn't change while you're developing (see the note under "Path mapping")
        dynamic/
            - do not serve dynamic content this way; proxy_pass to your own backend/container instead.
```
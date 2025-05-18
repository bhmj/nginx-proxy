## Path mapping

Local host path `/var/nginx-proxy/configs` is mapped into Nginx container as `/etc/nginx/conf.d`.  
Put the project config into `/var/nginx-proxy/configs` and run `docker exec nginx-proxy nginx -s reload`.

Local host path `/var/nginx-proxy/static` is mapped into Nginx container as `/var/www/`.
Copy static data for the project into `/var/nginx-proxy/static/<project_name>/` and it is ready to use.

## Usage

`make run` to run the Nginx proxy.

`make stop` to stop the Nginx proxy.

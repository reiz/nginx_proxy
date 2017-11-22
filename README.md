# nginx forward proxy

Usually Nginx is used as proxy or load balancer for incoming traffic. 
In this repository it is used as forward proxy. 

## Use Case

Assume you have a network where you want to control outgoing HTTP calls. 
You either want to: 

 - Only allow HTTP calls to whitelisted URLs
 - Only block HTTP calls to blacklisted URLs

The Docker daemon can be configured that way that it routes all traffic 
through an proxy. This proxy can be an Nginx witch is configured for forward proxying. 

## ngx_http_proxy_connect_module

Nginx is can be configured for forward proxying. 
Unfortunately that doesn't work very well with HTTPS connections. 
As soon the user is calling a URL via https, Nginx will throw errors. 
There is a [StackOverflow issue](https://superuser.com/questions/604352/nginx-as-forward-proxy-for-https)
to that topic. Luckily there is a solution for that problem. 
The [ngx_http_proxy_connect_module](https://github.com/chobits/ngx_http_proxy_connect_module)
is solving this problem. If Nginx is compiled with that module, 
the proxying will work with SSL connections as well. 

## Docker

The Dockerfile in this repository is assembling an Nginx with the ngx_http_proxy_connect_module
and an nginx.conf file which is whitelisting some domains, but bocks all outgoing traffic by default. 
The Docker image can be build like this: 

```
docker build -t reiz/nginx_proxy:0.0.1 . 
```

Or simply download it from [Docker Hub](https://hub.docker.com/r/reiz/nginx_proxy/) with: 

```
docker pull reiz/nginx_proxy:0.0.1
```

## Whitelist certain domains

This repository contains two nginx configuration files. 
The `nginx_whitelist.conf` file is build for the use case that you want to 
deny all outgoing traffic by default and only allow some whitelisted domains. 
In the first server section domains can be whitelisted by simply adding a 
`server_name *` line for each whitelisted domain. Here an example: 

```
    server {
        listen       8888;
        server_name  google.com;
        server_name  www.google.com;
        server_name  google.de;
        server_name  www.google.de;
        return 404;
    }
```

In the above example google.com would be whitelisted. You could reach Google, but no other site. 
By starting the Docker container the file can be mounted into the running container. 

```
docker run -d -p 8888:8888 -v nginx_whitelist.conf:/usr/local/nginx/conf/nginx.conf reiz/nginx_proxy:0.0.1 
```

Now the Docker container is running with the mounted configuration.

## Blacklist certain domains

This repository contains two nginx configuration files. 
The `nginx_blacklist.conf` file is build for the use case that you want to 
allow all outgoing traffic by default and only block traffic to some domains. 
In the first server section domains can be blacklisted by simply adding a 
`server_name *` line for each blacklisted domain. Here an example: 

```
    server {
        listen       8888;
        server_name  google.com;
        server_name  www.google.com;
        return 404;
    }
```

In the example above all pages would be accessable, but Google would be blocked.
By starting the Docker container the file can be mounted into the running container. 

```
docker run -d -p 8888:8888 -v nginx_whitelist.conf:/usr/local/nginx/conf/nginx.conf reiz/nginx_proxy:0.0.1 
```

Now the Docker container is running with the mounted configuration.


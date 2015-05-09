# docker-nginx-proxy

![nginx logo](http://comlounge.net/material/logos/logo-nginx.png)

---

# Dynamic Production **NGINX** Reverse-Proxy Server

![nginx 1.7.11](https://img.shields.io/badge/nginx-1.7.11-brightgreen.svg?style=flat-square)
![docker-gen 0.3.9](https://img.shields.io/badge/docker--gen-0.3.9-blue.svg?style=flat-square)
![forego 0.16.1](https://img.shields.io/badge/forego-0.16.1-blue.svg?style=flat-square)
![License MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square)

---

Dynamic **nginx** based reverse-proxy automatically generating (optional loadbalanced) upstreams and listening server endpoints. After a lot of reading experimenting and customizing - *IMHO* a selection of the best available free or open-source reverese-proxy/loadbalancer solutions available on the market.

Highly customizable for single endpoints, clustered servers or the whole machine. Multilevel stacking of several instances/cluster is possible to provide largest scalability support. 

You can create and scale a *server stack*/*stacked cluster* on your own, use the [docker-compose **scale**](https://docs.docker.com/compose/cli/#scale) option or operate with [docker swarm](https://docs.docker.com/swarm/#nodes-setup) for high availability massive multi user backend facade to your services.

---

Main **focus** on:

- Usability
- Performance
- Maintainability
- Security
- Extensibility
- Upgradeability

---

# Basics

**Jason Wilder** created nginx-proxy for docker based on his [docker-gen](https://registry.hub.docker.com/u/jwilder/docker-gen/) and **Igor Sysoev's** [nginx](http://nginx.org/ru/).

This is a widely redesigned and modified image that tries to improve his pretty open/generic reverse proxy image. Modifications are mostly intended by *my* common and especially production use cases.

**Many thanks to Jason for his great work!**

See also readme data at Jason's [github repo](https://github.com/jwilder/nginx-proxy) for more information about [docker-gen](https://github.com/jwilder/docker-gen), [templates](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/) and more.

---

# Contains


[nginx](http://nginx.org/ru/)
![nginx 1.7.11](https://img.shields.io/badge/nginx-1.7.11-brightgreen.svg?style=flat-square)

[docker-gen](https://github.com/jwilder/docker-gen)
&nbsp;&nbsp;&nbsp;&nbsp;![docker-gen 0.3.9](https://img.shields.io/badge/docker--gen-0.3.9-blue.svg?style=flat-square)

[forego](https://github.com/ddollar/forego)
![forego 0.16.1](https://img.shields.io/badge/forego-0.16.1-blue.svg?style=flat-square)

---

# Modifications

To make Jason's nginx-proxy more *configurable* for me without having to provide custom configs/includes, I added several **environment variables**. All of them change the global behavior of nginx or it's configured servers within the templating engine (starting with "*GLOB_*"). Excuse me Jason, I know you try to minimize amount of environment variables.

Another aim is to increase **performance** especially in multiple full ssl based environments - forcing ssl by default. It allows multilevel proxy data caching out of the box.

Last but not least I tried to improve **readability** and documentation for easier understanding of the image's working principles.

---

# Environment Variables

The image offers a lot of environment variables granting you many **customization** and **optimization** possibilities. They are as followed here:

## GLOB_USER_NAME
### Info
The user which will run the proxy server.
### Default 'nginx'

## GLOB_MAX_BODY_SIZE
### Info
Set the nginx maximum body size.
### Link 
See [nginx docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
### Default: 10m

## GLOB_CACHE_ENABLE
### Info
Enables the multi staging proxy caching to increase performance and reduce latency. Active by default.
### Default *1*

## GLOB_SSL_CERT_BUNDLE_INFIX
### Info
Set the insertion string inserted between cert file's name and cert file extension.

Ignored if *GLOB_SSL_CERT_BUNDLE_ENABLED* is *false*
### Default: "" ( <empty>)

## GLOB_SSL_SESSION_TIMEOUT
### Info
Change ssl session timeout.
### Link
See [nginx ssl docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_timeout)
### Default: 5m

## GLOB_SSL_SESSION_CACHE
### Info
Modify size of shared ssl session cache.
### Link
See [nginx ssl docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_cache)
### Default: 50m

## GLOB_SSL_OCSP_VALID_TIME
### Info
Enable Online Certificate Status Protocol (OCSP) through setting this value to any != 0. If 0, GLOB_SSL_OCSP_DNS_ADDRESSES and GLOB_SSL_OCSP_DNS_TIMEOUT are ignored. 
### Link
See [nginx stapling](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_stapling) for details
### Default: 0 (disabled)

## GLOB_SSL_OCSP_DNS_ADDRESSES
### Info
DNS servers (2) to resolve the certificate verification from. Unused if GLOB_SSL_OCSP_VALID_TIME = 0. Uses [OpenNicProject](http://www.opennicproject.org/) DNS server one of google's. You can use google one's only as well with e.g. "8.8.4.4 8.8.8.8".
### Link
See [nginx resolver](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver) for details
### Default: 5.9.49.12 8.8.8.8

## GLOB_SSL_OCSP_DNS_TIMEOUT
### Info
Timeout for name resolution. Unused if GLOB_SSL_OCSP_VALID_TIME = 0.
### Link
See [nginx resolver](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver) for details
### Default: 10s

## GLOB_HTTPS_FORCE
### Info
Redirect calls via http to https.
### Default 1

## GLOB_SPDY_ENABLED
### Info
Enable high speed ssl spdy protocol for supporting clients.
### Link
See [nginx spdy docs](http://nginx.org/en/docs/http/ngx_http_spdy_module.html)
### Default: 0

## GLOB_HTTP_NO_SERVICE
### Info
You may want to return another status code in case of not matching server requests.
### Default: 503

## GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED
### Info
To easily tell the proxy to redirect requests from a prefixed domain to the none prefixed one and vice versa.
### Default: 0

## GLOB_AUTO_REDIRECT_PREFIX
### Info
Provide a custom prefix to include with auto redirect.

Ignored if *GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED* is *false*

e.g. redirect 

    *www*.domain.org -> domain.org
    domain.org -> *www*.domain.org

    *api*.domain.org -> domain.org
    domain.org -> *cdn*.domain.org
### Default: www

## GLOB_AUTO_REDIRECT_DIRECTION
### Info
To control source and destination of auto redirect:

- 0: redirect from prefix to non-prefix
- 1: redirect from non-prefix to prefix
### Default: 0

## GLOB_ALLOW_HTTP_FALLBACK
###Info
As HTTPS/SSL is enabled by default, this flag allows acces via HTTP as well.
### Default 0

## GLOB_WORKER_COUNT
### Info
Set the maximum amount of concurrent worker processes of the server. 
### Default auto
Defaults to auto -> means server tries to find the best amount according to the CPU cores. (i.e. 2 * core count)

## GLOB_WORKER_CONNECTIONS
### Info
Specifies the total count of concurrent simultaneous connection for each worker.
### Default *256*

## GLOB_WORKER_MULTI_ACCEPT
### Info
Allows the workers to handle multiple connections at once.
Set to '*off*' if you want the worker to always handle only one connection at a time.
### Default on

## GLOB_WORKER_RLIMIT_NOFILE
### Info
Defines the possible highest number of file handles a worker can hold concurrently.
### Default *1024*

## GLOB_ERROR_LOG_LEVEL
### Info
Sets the loglevel for the **error** log output to print.
### Possible
* error
* warn
* info
* debug
### Default '*error*'

## GLOB_KEEPALIVE_TIMEOUT
### Info
The time a worker will hold a connection to a client without a request in seconds.
### Default 60

## GLOB_UPSTREAM_IDLE_CONNECTIONS
### Info
The number of connections to the upstream backend services that will be kept idle at maximum from nginx. It's turned off by default but with setting a value like 20 - there are always some idle connections available. This reduces the amount of HTTP/TCP connections that need to be created from scratch. This avoids the so called [HTTP Heavy Lifting](http://nginx.com/blog/http-keepalives-and-web-performance/)
### Default 0

## GLOB_TMPL_MODE
### Info
By default the nginx configuration file is generated from *run*-template. For development issues you can set this variable to '*dev*' to have a more readable template to work on. Logical both the *run* and the *dev* template are doing the same.
### Default *run*

## DOCKER_GEN_VERSION
### Info
The version of docker-gen to use.
### Default *0.3.9*

## DOCKER_HOST
### Info
The docker host this image is working with/to. You can run a docker container only for the proxies to manage another docker container running the applications.
### Default '*unix:///tmp/docker.sock*'

# Quickstart

    docker run -it -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock mkodockx/docker-nginx-proxy
    
# Maximum Customization

    docker run -d --name "mgt-op" \
        -p 80:80 -p 443:443 \
        -e GLOB_MAX_BODY_SIZE="1g" \
        -e GLOB_SSL_SESSION_TIMEOUT="10m" \
        -e GLOB_SSL_SESSION_CACHE="100m" \
        -e GLOB_SSL_CERT_BUNDLE_INFIX=".chained" \
        -e GLOB_ALLOW_HTTP_FALLBACK="1" \
        -e GLOB_HTTPS_FORCE="0"
        -e GLOB_SPDY_ENABLED="1" \
        -e GLOB_HTTP_NO_SERVICE="404" \
        -e GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED="1" \
        -e GLOB_AUTO_REDIRECT_PREFIX="subservice" \
        -e AUTO_REDIRECT_DIRECTION="1" \
        -v /etc/certs:/etc/nginx/certs \
        -v /var/run/docker.sock:/tmp/docker.sock mkodockx/docker-nginx-proxy
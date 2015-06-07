# docker-nginx-proxy

![nginx logo](http://comlounge.net/material/logos/logo-nginx.png)

---

# **NGINX** DD RPS

- DD -> Dynamic Docker
- RPS -> Reverse Proxy Server

![nginx 1.9.0](https://img.shields.io/badge/nginx-1.9.0-brightgreen.svg?style=flat-square)
![docker-gen 0.3.9](https://img.shields.io/badge/docker--gen-0.3.9-blue.svg?style=flat-square)
![forego 0.16.1](https://img.shields.io/badge/forego-0.16.1-blue.svg?style=flat-square)
![License MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square)

# Quickstart

    docker run -it -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock mkodockx/docker-nginx-proxy

# About

A **nginx** based reverse-proxy with dynamic server configuration at runtime. Automatically generating **nginx** configuration data triggered by Docker events.

Easily customizable for specific use cases. Multilevel stacking of instances is possible to provide scalability support. 

You can create and scale the backend via (beta) Docker mechanisms: 
Use the [docker-compose **scale**](https://docs.docker.com/compose/cli/#scale) option or operate with [docker swarm](https://docs.docker.com/swarm/#nodes-setup) to ensure *high-availability*.

You can use nginx balancing capabilities as well with different balancing methods, persistence variants, weighting and more. See [nginx load_balancing docs](http://nginx.org/en/docs/http/load_balancing.html) for details.

My main **focus** on:

- Performance
- Security

---

# Basics

**[Jason Wilder](https://github.com/jwilder)** created [nginx-proxy](https://github.com/jwilder/nginx-proxy) for docker based on his [docker-gen](https://registry.hub.docker.com/u/jwilder/docker-gen/) and **Igor Sysoev's** [nginx](http://nginx.org/ru/).

This fork is some kind of refactoring and extension of Jason's primarily work. So I modified a lot but I didn't change the core functionality itself. Modifications are triggered by division and extension to be able to meet my demands.

However:
**Many thanks to Jason for his great work!**

See also readme data at Jason's [github repo](https://github.com/jwilder/nginx-proxy) for more information about [docker-gen](https://github.com/jwilder/docker-gen), [templates](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/) and more.

---

# Contains


[nginx](http://nginx.org/ru/)
&nbsp;&nbsp;![nginx 1.9.0](https://img.shields.io/badge/nginx-1.9.0-brightgreen.svg?style=flat-square)

[docker-gen](https://github.com/jwilder/docker-gen)
&nbsp;&nbsp;![docker-gen 0.3.9](https://img.shields.io/badge/docker--gen-0.3.9-blue.svg?style=flat-square)

[forego](https://github.com/ddollar/forego)
&nbsp;&nbsp;![forego 0.16.1](https://img.shields.io/badge/forego-0.16.1-blue.svg?style=flat-square)

---

# Modifications

## More global env vars

To make Jason's nginx-proxy more *configurable* for me without having to provide custom configs/includes, I added some **environment variables**. (I'm sorry Jason, I know you try to minimize amount of environment variables)

All of them change the global behavior of nginx. (starting with "*GLOB_*")

Using this image you can easily modify relevant values, configs or features via environment variables.

For example:
- Caching/Proxy-Caching
- SSL: Bundled Certs / CA chains
- SSL: OCSP
- automatic redirects
- nginx worker config

Optional: Easy using of optimisation features of **nginx** as they are provided in general but must be activated via environment variables.

Further I added connection/IP based simple handling of request amount peaks.

## More container env vars

### VIRTUAL_STATIC_FILE_CONFIG

#### Info

If you have a volume mounted from docker host to container, you can enable **X-Accel** headers to be handled by nginx. So if you have a webserver (e.g. [httpd/Apache](http://httpd.apache.org/) or another [nginx](http://nginx.org/)) within the container image, it could be skipped and nginx will serve static files instead. That could provide a performance increase possibly - although not in any case.

It is possible, to serve sensitive files from one provider (e.g. private-cloud) and use another provider (e.g. public-cloud) for non-sensitive files - to create a hybrid cloud. Pretty easy an simple from one logical nginx-

e.g. owncloud with fastcgi -> [fastcgi_param MOD_X_ACCEL_REDIRECT_ENABLED on;](https://doc.owncloud.org/server/5.0/admin_manual/configuration/xsendfile.html)

**Besides**:
*This allows you to use one static file provider for several container in your desired configuration. So you may use a CDN for images, EC2 instance for '.php' and more.*

#### How to

**STATIC_FILE_CONFIG** requires two arguments and accepts up to 3:

##### URI
Trigger for the static file handling. Definition by a prefix string or by a regular expression - [docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)
e.g. "/" or "^~ /images/"

##### Target
Definition of the path or URL to serve the static files from. Depending on which kind to use, value can vary.

##### Kind (optional)

- root (*default*)

  Sets the base path of files requested. e.g. "/var/www/static"

- alias

  Link to an absolute path on host. e.g. "/var/www/static/files_path"

- proxy_pass

  Link to a content deliverer like amazonaws or CDN. e.g. "http://cdn.com"

See [synopsis](http://wiki.nginx.org/X-accel)

#### Pattern

##### Simple

    VIRTUAL_STATIC_FILE_CONFIG="<# uri #><# seperator #><# target #>

##### Custom kind

    VIRTUAL_STATIC_FILE_CONFIG="<# uri #><# seperator #><# target #><# seperator #><# kind #>

#### Example

##### Default kind (root)

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_STATIC_FILE_CONFIG="/images>/var/local/static/images" \
        ... target/image

##### Custom kind

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_STATIC_FILE_CONFIG="/images>/var/local/static/images>alias" \
        ... target/image

### VIRTUAL_STATIC_CONFIG_ITEM_SEPERATOR

#### Info

Depending on which kind of URI/regex you want to use, you may want to change the seperator.

Default: **">"**

#### Pattern

    VIRTUAL_STATIC_CONFIG_ITEM_SEPERATOR="<# seperator-string #>"

#### Example

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_STATIC_CONFIG_ITEM_SEPERATOR=":" \
        -e VIRTUAL_STATIC_FILE_CONFIG="/images:/var/local/static/images" \
        ... target/image

### VIRTUAL_SSL_FORCE

#### Info

Change global https enforcing policy for a single container.

Default: value of [GLOB_SSL_FORCE](## GLOB_SSL_FORCE) - which defaults to "1"

#### Pattern

    VIRTUAL_SSL_FORCE="<# vals "0" or "1" #>"

#### Example

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_SSL_FORCE="0" \
        ... target/image

## More understanding

Last but not least I tried to improve **readability** and documentation for easier understanding of the image's working principles. From my point of view. Therefore this repo contains an additional [nginx-dev template](https://github.com/mko-x/docker-nginx-proxy/blob/master/container-data/nginx-dev.tmpl) with a lot of documentation. That's just for my reference, you may have a look and try it yourself.

---

# Environment Variables

The image offers a bunch of environment variables allowing you easy **customization** and **optimization** even for more complex features.

---
## GLOB_USER_NAME
### Info
The user which will run the proxy server.
### Default:'nginx'
---
## GLOB_MAX_BODY_SIZE
### Info
Set the nginx maximum body size.
### Link 
See [nginx docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)
### Default: 10m
---
## GLOB_CACHE_ENABLE
### Info
Enables the multi staging proxy caching to increase performance and reduce latency. Active by default.
### Default: *1*
---
## GLOB_SSL_CERT_BUNDLE_INFIX
### Info
Set the insertion string inserted between cert file's name and cert file extension.Ignored if *GLOB_SSL_CERT_BUNDLE_ENABLED* is *false*
### Default: "" ( empty)
---
## GLOB_SSL_SESSION_TIMEOUT
### Info
Change ssl session timeout.
### Link
See [nginx ssl docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_timeout)
### Default: 5m
---
## GLOB_SSL_SESSION_CACHE
### Info
Modify size of shared ssl session cache.
### Link
See [nginx ssl docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_session_cache)
### Default: 50m
---
## GLOB_SSL_OCSP_VALID_TIME
### Info
Enable Online Certificate Status Protocol (OCSP) through setting this value to any != 0. If 0, GLOB_SSL_OCSP_DNS_ADDRESSES and GLOB_SSL_OCSP_DNS_TIMEOUT are ignored. 
### Link
See [nginx stapling docs](http://nginx.org/en/docs/http/ngx_http_ssl_module.html#ssl_stapling) for details
### Default: 0 (disabled)
---
## GLOB_SSL_OCSP_DNS_ADDRESSES
### Info
DNS servers (2) to resolve the certificate verification from. Unused if GLOB_SSL_OCSP_VALID_TIME = 0. Uses [OpenNicProject](http://www.opennicproject.org/) DNS server and one provided by google. You can use google one's only as well with setting to e.g. "8.8.4.4 8.8.8.8".
### Link
See [nginx resolver docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver) for details
### Default: 5.9.49.12 8.8.8.8
---
## GLOB_SSL_OCSP_DNS_TIMEOUT
### Info
Timeout for name resolution. Unused if GLOB_SSL_OCSP_VALID_TIME = 0.
### Link
See [nginx resolver docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#resolver) for details
### Default: 10s
---
## GLOB_SSL_FORCE
### Info
Redirect calls via http to https.
### Default: 1
---
## GLOB_DEFAULT_HOST
### Info
To set the default host for nginx use the env var `GLOB_DEFAULT_HOST=foo.bar.com`. 
### Default: $host (current target host)

---
## GLOB_SPDY_ENABLED
### Info
Enable high speed ssl spdy protocol for supporting clients.
### Link
See [nginx spdy docs](http://nginx.org/en/docs/http/ngx_http_spdy_module.html)
### Default: 0
---
## GLOB_HTTP_NO_SERVICE
### Info
You may want to return another status code in case of not matching server requests.
### Default: 503
---
## GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED
### Info
To easily tell the proxy to redirect requests from a prefixed domain to the none prefixed one and vice versa.
### Default: 0
---
## GLOB_AUTO_REDIRECT_PREFIX
### Info
Provide a custom prefix to include with auto redirect. Ignored if *GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED* is *false*
use-cases: 
- *www*.domain.org -> domain.org
- domain.org -> *www*.domain.org
- *api*.domain.org -> domain.org
- domain.org -> *cdn*.domain.org

### Default: www

---
## GLOB_AUTO_REDIRECT_DIRECTION
### Info
To control source and destination of auto redirect. Ignored if GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED is not enabled.
- 0: redirect from prefix to non-prefix
- 1: redirect from non-prefix to prefix

### Default: 0

---
## GLOB_ALLOW_HTTP_FALLBACK
###Info
As HTTPS/SSL is enabled by default, this flag allows acces via HTTP as well.
### Default: 0
---
## GLOB_WORKER_COUNT
### Info
Set the maximum amount of concurrent worker processes of the server. 
### Default: auto
Defaults to auto -> usually count of available CPU cores.
---
## GLOB_WORKER_CONNECTIONS
### Info
Specifies the total count of concurrent simultaneous connection for each worker.
### Default: *256*
---
## GLOB_WORKER_MULTI_ACCEPT
### Info
Allows the workers to handle multiple connections at once. Set to '*off*' if you want the worker to always handle only one connection at a time.
### Default: on
---
## GLOB_WORKER_RLIMIT_NOFILE
### Info
Defines the possible highest number of file handles a worker can hold concurrently.
### Default: *1024*
---
## GLOB_ERROR_LOG_LEVEL
### Info
Sets the loglevel for the **error** log output to print.
Choose from: crit, error, warn, info, debug
### Default: *error*
---
## GLOB_KEEPALIVE_TIMEOUT
### Info
The time a worker will hold a connection to a client without a request in seconds.
### Default: 60
---
## GLOB_UPSTREAM_IDLE_CONNECTIONS
### Info
The number of connections to the upstream backend services that will be kept idle at maximum from nginx. It's turned off by default but with setting a value like 20 - there are always some idle connections available. This reduces the amount of HTTP/TCP connections that need to be created from scratch. This avoids the so called [HTTP Heavy Lifting](http://nginx.com/blog/http-keepalives-and-web-performance/)

### Default: 0
---
## GLOB_TMPL_MODE
### Info
By default the nginx configuration file is generated from *run*-template. For development issues you can set this variable to '*dev*' to have a more readable template to work on. Logical both the *run* and the *dev* template are doing the same.
### Default: *run*
---
## DOCKER_GEN_VERSION
### Info
The version of docker-gen to use.
### Default: *0.3.9*
---
## DOCKER_HOST
### Info
The docker host this image is working with/to. You can run a docker container only for the proxies to manage another docker container running the applications.
### Default: '*unix:///tmp/docker.sock*'
---
## GLOB_LIMIT_CONS_PER_IP
### Info
Define the maximum amount of connections per IP to allowed. If limit is exceeded, server will not respond to this IP for next 5 minutes. Protects the proxy from DOS via connection overflow.
### Default: 50
---
## GLOB_LIMIT_REQS_BURST
### Info
Define the peak amount of requests per connection allowed. If a client 
ENV GLOB_LIMIT_REQS_BURST 80



# Big Customization

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
        
# More
Further information about several settings, reasons and the consequences.

Just short explanations.

## sendfile on
It depends somehow on the use-case and the used kernel. But in general the sendfile implementation just 'pipes'(not exactly) information from one file descriptor(FD) to another within the kernel. So we have a decent direct disk I/O.

By default sendfile is off. That causes the kernel to first read data from one FD, then writes it to the target FD.

time of (*read()*  +  *write()*)  >  time of (*sendfile()*)

## tcp_nodelay on
The TCP stack has a mechanism implemented to avoid sending of too small packets. This mechanism will wait for a certain time to guarantee a packet is filled. The UNIX implementation is about 200ms. This mechanism is called [Nagle’s algorithm](http://en.wikipedia.org/wiki/Nagle's_algorithm). That was defined 1984.

Today most of the data sent within a request/response exceeds the limit of one frame. But it's impossible to eactly fill it to the limit. So one can guess about 90% of traffic we have useless 200ms waiting for each packet.

Activating this option will add the TCP_NODELAY option on the current connection's TCP stack.

## tcp_nopush on
As with tcp_nodelay will reduce waiting time, tcp_nopush tries to reduce the data size transmitted. As only FreeBSD is implementing TCP_NOPUSH in the TCP stack nginx will activate the TCP_CORK option on Linux. 

Just like a real cork it blocks the outgoing packet until it reaches the critical mass to be worth transferring.

The mechanism is pretty well documented in the Linux kernel [source code](http://lxr.free-electrons.com/source/net/ipv4/tcp_output.c?a=avr32#L1469).

## sendfile + tcp_nodelay + tcp_nopush
I leave to you now to combine the three effects and realize their benefits.

If you don't get it, Frederic made a pretty good post([original (french)](https://t37.net/optimisations-nginx-bien-comprendre-sendfile-tcp-nodelay-et-tcp-nopush.html)/[english](https://t37.net/nginx-optimization-understanding-sendfile-tcp_nodelay-and-tcp_nopush.html) ) according to this topic. 
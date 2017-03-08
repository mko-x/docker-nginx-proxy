# docker-nginx-proxy

![nginx logo](https://bebrand.de/l/nginx.png)

---

# **NGINX** DD RPS

- DD -> Dynamic Docker
- RPS -> Reverse Proxy Server

![nginx 1.10.3](https://img.shields.io/badge/nginx-1.10.3-brightgreen.svg?style=flat-square)
![docker-gen 0.7.3](https://img.shields.io/badge/docker--gen-0.7.3-blue.svg?style=flat-square)
![forego 0.16.1](https://img.shields.io/badge/forego-0.16.1-blue.svg?style=flat-square)
![License MIT](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat-square)

# Quickstart

## Latest Stable

    docker run -it -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro mkodockx/docker-nginx-proxy:stable

## Latest Master

    docker run -it -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro mkodockx/docker-nginx-proxy

# About

A **nginx** based reverse-proxy with dynamic server configuration at runtime. Automatically generating configuration data triggered by Docker events.

Easily customizable for specific use cases. Multilevel stacking of instances is possible to provide scalability support. 

You can create and scale the backend via (beta) Docker mechanisms: 
Use the [docker-compose **scale**](https://docs.docker.com/compose/cli/#scale) option or operate with [docker swarm](https://docs.docker.com/swarm/#nodes-setup).

It provides/uses [nginx](http://nginx.org/ru/) limiting capabilities with different detection methods by default (connections per ip, burst requests/s).

---

# Basics

## FROM

**[Jason Wilder](https://github.com/jwilder)** created [nginx-proxy](https://github.com/jwilder/nginx-proxy) for docker based on his [docker-gen](https://registry.hub.docker.com/u/jwilder/docker-gen/) and [nginx](http://nginx.org/ru/) created by **Igor Sysoev**.

This fork is some kind of refactoring and extension of Jason's primarily work. So I modified a lot but I didn't change the core functionality itself. Modifications are triggered by division and extension to be able to meet my demands.

## Thanks

**Many thanks to Jason for his great work!**

## More

See also the readme at Jason's [github repo](https://github.com/jwilder/nginx-proxy) for more information about [docker-gen](https://github.com/jwilder/docker-gen) and look at his site for information about [templates](http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/).

Topics covered there among others:

- Multi Port
- Multi Hosts
- Wildcard Hosts

- SSL Config
- Basic Auth

- Custom global or per vhost [nginx](http://nginx.org/ru/) configuration

You find a copy of Jason's readme at the end of this one. It's just to easyily provide the version of his readme according to my fork.

---

# Contains


[nginx](http://nginx.org/ru/)
&nbsp;&nbsp;![nginx stable](https://img.shields.io/badge/nginx-stable-brightgreen.svg?style=flat-square)

[docker-gen](https://github.com/jwilder/docker-gen)
&nbsp;&nbsp;![docker-gen 0.7.3](https://img.shields.io/badge/docker--gen-0.7.3-blue.svg?style=flat-square)

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
- CORS support
- [nginx](http://nginx.org/ru/) worker config

Optional: Easy using of optimisation features of [nginx](http://nginx.org/ru/) as they are provided in general but must be activated via environment variables.

Further I added connection/IP based simple handling of request amount peaks.

See details [below](# Global Environment Variables)

## More container env vars

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

### VIRTUAL_ORIGINS

#### Info

Allow additional origins to support [CORS](https://de.wikipedia.org/wiki/Cross-Origin_Resource_Sharing).

#### Pattern

    VIRTUAL_ORIGINS="<proto>://<domain>.<tld>"

#### Example

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_ORIGINS=cdn.org \
        ... target/image
        
#### Allow all

    docker run -v /var/local/static/images:/var/www/images \
        -e VIRTUAL_HOST=example.org \
        -e VIRTUAL_ORIGINS="*" \
        ... target/image

## More understanding

Last but not least I tried to improve **readability** and documentation for easier understanding of the image's working principles. From my point of view. Therefore this repo contains an additional [nginx-dev template](https://github.com/mko-x/docker-nginx-proxy/blob/master/container-data/nginx-dev.tmpl) with a lot of documentation. That's just for my reference, you may have a look and try it yourself.

---

# Global Environment Variables

The image offers a bunch of environment variables allowing you easy **customization** and **optimization** even for more complex features.

---
## GLOB_USER_NAME
### Info
The user which will run the proxy server.
### Default:'nginx'
---
## GLOB_MAX_BODY_SIZE
### Info
Set the [nginx](http://nginx.org/ru/) maximum body size.
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
To set the default host for [nginx](http://nginx.org/ru/) use the env var `GLOB_DEFAULT_HOST=foo.bar.com`. 
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
By default the [nginx](http://nginx.org/ru/) configuration file is generated from *run*-template. For development issues you can set this variable to '*dev*' to have a more readable template to work on. Logical both the *run* and the *dev* template are doing the same.
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
You may need to exceed that for bigger applications like JIRA.
### Default: 50
---
## GLOB_LIMIT_REQS_BURST
### Info
Define the peak amount of requests per connection allowed. If a client exceeds that, no more requests will be forwardded.
You may need to exceed that for bigger applications like JIRA.
### Default: 80
---
## GLOB_WILD_CORS
### Info
Allows any cross origin requests globally.
### Default: 0

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
        -v /var/run/docker.sock:/tmp/docker.sock:ro mkodockx/docker-nginx-proxy
        
# Details
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
As with tcp_nodelay will reduce waiting time, tcp_nopush tries to reduce the data size transmitted. As only FreeBSD is implementing TCP_NOPUSH in the TCP stack [nginx](http://nginx.org/ru/) will activate the TCP_CORK option on Linux. 

Just like a real cork it blocks the outgoing packet until it reaches the critical mass to be worth transferring.

The mechanism is pretty well documented in the Linux kernel [source code](http://lxr.free-electrons.com/source/net/ipv4/tcp_output.c?a=avr32#L1469).

## sendfile + tcp_nodelay + tcp_nopush
I leave to you now to combine the three effects and realize their benefits.

If you don't get it, Frederic made a pretty good post([original (french)](https://t37.net/optimisations-nginx-bien-comprendre-sendfile-tcp-nodelay-et-tcp-nopush.html)/[english](https://t37.net/nginx-optimization-understanding-sendfile-tcp_nodelay-and-tcp_nopush.html) ) according to this topic. 

# Origin Docs (commit 6719f7636fc63a9d4f4fc349aae03e2fe9a15a45)

![nginx 1.9.0](https://img.shields.io/badge/nginx-1.9.0-brightgreen.svg) ![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

nginx-proxy sets up a container running nginx and [docker-gen][1].  docker-gen generates reverse proxy configs for nginx and reloads nginx when containers are started and stopped.

See [Automated Nginx Reverse Proxy for Docker][2] for why you might want to use this.

### Usage

To run it:

    $ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

Then start any containers you want proxied with an env var `VIRTUAL_HOST=subdomain.youdomain.com`

    $ docker run -e VIRTUAL_HOST=foo.bar.com  ...

Provided your DNS is setup to forward foo.bar.com to the a host running nginx-proxy, the request will be routed to a container with the VIRTUAL_HOST env var set.

### Multiple Ports

If your container exposes multiple ports, nginx-proxy will default to the service running on port 80.  If you need to specify a different port, you can set a VIRTUAL_PORT env var to select a different one.  If your container only exposes one port and it has a VIRTUAL_HOST env var set, that port will be selected.

  [1]: https://github.com/jwilder/docker-gen
  [2]: http://jasonwilder.com/blog/2014/03/25/automated-nginx-reverse-proxy-for-docker/

### Multiple Hosts

If you need to support multiple virtual hosts for a container, you can separate each entry with commas.  For example, `foo.bar.com,baz.bar.com,bar.com` and each host will be setup the same.

### Wildcard Hosts

You can also use wildcards at the beginning and the end of host name, like `*.bar.com` or `foo.bar.*`. Or even a regular expression, which can be very useful in conjunction with a wildcard DNS service like [xip.io](http://xip.io), using `~^foo\.bar\..*\.xip\.io` will match `foo.bar.127.0.0.1.xip.io`, `foo.bar.10.0.2.2.xip.io` and all other given IPs. More information about this topic can be found in the nginx documentation about [`server_names`](http://nginx.org/en/docs/http/server_names.html).

### SSL Backends

If you would like to connect to your backend using HTTPS instead of HTTP, set `VIRTUAL_PROTO=https` on the backend container.

### Default Host

To set the default host for nginx use the env var `DEFAULT_HOST=foo.bar.com` for example

    $ docker run -d -p 80:80 -e DEFAULT_HOST=foo.bar.com -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy


### Separate Containers

nginx-proxy can also be run as two separate containers using the [jwilder/docker-gen](https://index.docker.io/u/jwilder/docker-gen/)
image and the official [nginx](https://registry.hub.docker.com/_/nginx/) image.

You may want to do this to prevent having the docker socket bound to a publicly exposed container service.

To run nginx proxy as a separate container you'll need to have [nginx.tmpl](https://github.com/jwilder/nginx-proxy/blob/master/nginx.tmpl) on your host system.

First start nginx with a volume:


    $ docker run -d -p 80:80 --name nginx -v /tmp/nginx:/etc/nginx/conf.d -t nginx

Then start the docker-gen container with the shared volume and template:

```
$ docker run --volumes-from nginx \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    -v $(pwd):/etc/docker-gen/templates \
    -t jwilder/docker-gen -notify-sighup nginx -watch -only-exposed /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
```

Finally, start your containers with `VIRTUAL_HOST` environment variables.

    $ docker run -e VIRTUAL_HOST=foo.bar.com  ...

### SSL Support

SSL is supported using single host, wildcard and SNI certificates using naming conventions for
certificates or optionally specifying a cert name (for SNI) as an environment variable.

To enable SSL:

    $ docker run -d -p 80:80 -p 443:443 -v /path/to/certs:/etc/nginx/certs -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

The contents of `/path/to/certs` should contain the certificates and private keys for any virtual
hosts in use.  The certificate and keys should be named after the virtual host with a `.crt` and
`.key` extension.  For example, a container with `VIRTUAL_HOST=foo.bar.com` should have a
`foo.bar.com.crt` and `foo.bar.com.key` file in the certs directory.

#### Diffie-Hellman Groups

If you have Diffie-Hellman groups enabled, the files should be named after the virtual host with a
`dhparam` suffix and `.pem` extension. For example, a container with `VIRTUAL_HOST=foo.bar.com`
should have a `foo.bar.com.dhparam.pem` file in the certs directory.

#### Wildcard Certificates

Wildcard certificates and keys should be name after the domain name with a `.crt` and `.key` extension.
For example `VIRTUAL_HOST=foo.bar.com` would use cert name `bar.com.crt` and `bar.com.key`.

#### SNI

If your certificate(s) supports multiple domain names, you can start a container with `CERT_NAME=<name>`
to identify the certificate to be used.  For example, a certificate for `*.foo.com` and `*.bar.com`
could be named `shared.crt` and `shared.key`.  A container running with `VIRTUAL_HOST=foo.bar.com`
and `CERT_NAME=shared` will then use this shared cert.

#### How SSL Support Works

The SSL cipher configuration is based on [mozilla nginx intermediate profile](https://wiki.mozilla.org/Security/Server_Side_TLS#Nginx) which
should provide compatibility with clients back to Firefox 1, Chrome 1, IE 7, Opera 5, Safari 1,
Windows XP IE8, Android 2.3, Java 7.  The configuration also enables HSTS, and SSL
session caches.

The behavior for the proxy when port 80 and 443 are exposed is as follows:

* If a container has a usable cert, port 80 will redirect to 443 for that container so that HTTPS
is always preferred when available.
* If the container does not have a usable cert, a 503 will be returned.

Note that in the latter case, a browser may get an connection error as no certificate is available
to establish a connection.  A self-signed or generic cert named `default.crt` and `default.key`
will allow a client browser to make a SSL connection (likely w/ a warning) and subsequently receive
a 503.

### Basic Authentication Support

In order to be able to securize your virtual host, you have to create a file named as its equivalent VIRTUAL_HOST variable on directory
/etc/nginx/htpasswd/$VIRTUAL_HOST

```
$ docker run -d -p 80:80 -p 443:443 \
    -v /path/to/htpasswd:/etc/nginx/htpasswd \
    -v /path/to/certs:/etc/nginx/certs \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy
```

You'll need apache2-utils on the machine you plan to create de htpasswd file. Follow these [instructions](http://httpd.apache.org/docs/2.2/programs/htpasswd.html)

### Custom Nginx Configuration

If you need to configure Nginx beyond what is possible using environment variables, you can provide custom configuration files on either a proxy-wide or per-`VIRTUAL_HOST` basis.

#### Proxy-wide

To add settings on a proxy-wide basis, add your configuration file under `/etc/nginx/conf.d` using a name ending in `.conf`.

This can be done in a derived image by creating the file in a `RUN` command or by `COPY`ing the file into `conf.d`:

```Dockerfile
FROM jwilder/nginx-proxy
RUN { \
      echo 'server_tokens off;'; \
      echo 'client_max_body_size 100m;'; \
    } > /etc/nginx/conf.d/my_proxy.conf
```

Or it can be done by mounting in your custom configuration in your `docker run` command:

    $ docker run -d -p 80:80 -p 443:443 -v /path/to/my_proxy.conf:/etc/nginx/conf.d/my_proxy.conf:ro -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy

#### Per-VIRTUAL_HOST

To add settings on a per-`VIRTUAL_HOST` basis, add your configuration file under `/etc/nginx/vhost.d`. Unlike in the proxy-wide case, which allows mutliple config files with any name ending in `.conf`, the per-`VIRTUAL_HOST` file must be named exactly after the `VIRTUAL_HOST`.

In order to allow virtual hosts to be dynamically configured as backends are added and removed, it makes the most sense to mount an external directory as `/etc/nginx/vhost.d` as opposed to using derived images or mounting individual configuration files.

For example, if you have a virtual host named `app.example.com`, you could provide a custom configuration for that host as follows:

    $ docker run -d -p 80:80 -p 443:443 -v /path/to/vhost.d:/etc/nginx/vhost.d:ro -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy
    $ { echo 'server_tokens off;'; echo 'client_max_body_size 100m;'; } > /path/to/vhost.d/app.example.com

If you are using multiple hostnames for a single container (e.g. `VIRTUAL_HOST=example.com,www.example.com`), the virtual host configuration file must exist for each hostname. If you would like to use the same configuration for multiple virtual host names, you can use a symlink:

    $ { echo 'server_tokens off;'; echo 'client_max_body_size 100m;'; } > /path/to/vhost.d/www.example.com
    $ ln -s www.example.com /path/to/vhost.d/example.com

![nginx 1.7.10](https://img.shields.io/badge/style-flat--squared-brightgreen.svg?nginx=1.7.10)
![License MIT](https://img.shields.io/badge/style-flat--squared-lightgrey.svg?license=MIT)

# Dynamic Production Reverse Proxy

![nginx logo](http://comlounge.net/material/logos/logo-nginx.png)

High dynamic and automatically generating reverse proxy created from a selection of the *IMHO* best available solutions at the moment.

**Focus** on:

- Usability
- Performance
- Maintainability
- Security

# Underlying Base 

Jason Wilder created nginx-proxy for docker based on his [docker-gen](https://registry.hub.docker.com/u/jwilder/docker-gen/) and Igor Sysoev's nginx.

This largely redesigned and modified image tries to improve his pretty open/generic reverse proxy image for my common and especially production use cases.

Many thanks to Jason for his great work.

See readme data at Jason's [github repo](https://github.com/jwilder/nginx-proxy).

**Uses**:

- [nginx](http://nginx.org/ru/) ![nginx 1.7.10](https://img.shields.io/badge/style-flat--squared-brightgreen.svg?nginx=1.7.10)
- [docker-gen](https://github.com/jwilder/docker-gen) ![docker-gen 0.3.7](https://img.shields.io/badge/style-flat--squared-blue.svg?docker-gen=0.3.7)
- [forego](https://github.com/ddollar/forego) ![forego 0.16.1](https://img.shields.io/badge/style-flat--squared-blue.svg?forego-gen=0.16.1)

# Modifications

To make Jason's nginx-proxy more configurable without having to provide custom configs/includes, I added some env vars. All of them change the global behavior of nginx or it's configured servers within the templating engine (starting with "GLOB_"). 

Another aim is to increase performance especially in multiple full ssl based environments.

Last but not least I tried to improve readability and documentation for easier understanding of the image's working principle.

# Environment Variables

Following environment variables are available:

## GLOB_MAX_BODY_SIZE

### Info

Set the nginx maximum body size.

### Link 

See [nginx docs](http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size)

### Default: 10m

## GLOB_SSL_CERT_BUNDLE_ENABLED

### Info
To ensure *CA-chain reliability*, some certificate providers deliver some kind of intermediate certificate to guarantee their authority. For nginx this cert and your own cert have to be concatenated to a bundle. 

If enabled you should provide that concatenated certificate additionally to your cert, marked by some kind of insertion between original file (i.e. domain) name.

e.g. domain.org.crt -> domain.org.bundle.crt 

### Link

See the [nginx https servers docs](http://nginx.org/en/docs/http/configuring_https_servers.html#chains) for further information.

### Default: false

## GLOB_SSL_CERT_BUNDLE_INFIX

### Info

Set the insertion string inserted between cert file's name and cert file extension.

Ignored if *GLOB_SSL_CERT_BUNDLE_ENABLED* is *false*

### Default: .bundle

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

## GLOB_SPDY_ENABLED

### Info

Enable high speed ssl spdy protocol for supporting clients.

### Link

See [nginx spdy docs](http://nginx.org/en/docs/http/ngx_http_spdy_module.html)

### Default: false

## GLOB_HTTP_NO_SERVICE

### Info

You may want to return another status code in case of not matching server requests.

### Default: 503

## GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED

### Info

To easily tell the proxy to redirect requests from a prefixed domain to the none prefixed one and vice versa.

### Default: false

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

# Quickstart

    docker run -it -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock mkodockx/docker-nginx-proxy
    
# Maximum Customization

    docker run -d --name "mgt-op" \
        -p 80:80 -p 443:443 \
        -e 'GLOB_MAX_BODY_SIZE=1g' \
        -e 'GLOB_SSL_SESSION_TIMEOUT=10m' \
        -e 'GLOB_SSL_SESSION_CACHE=100m' \
        -e 'GLOB_SSL_CERT_BUNDLE_INFIX=.chained' \
        -e 'GLOB_SSL_CERT_BUNDLE_ENABLED=true' \
        -e 'GLOB_SPDY_ENABLED=true' \
        -e 'GLOB_HTTP_NO_SERVICE=404' \
        -e 'GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED=true' \
        -e 'GLOB_AUTO_REDIRECT_PREFIX=subservice' \
        -e 'AUTO_REDIRECT_DIRECTION=1' \
        -v /etc/certs:/etc/nginx/certs \
        -v /var/run/docker.sock:/tmp/docker.sock mkodockx/docker-nginx-proxy
![nginx 1.7.8](https://img.shields.io/badge/nginx-1.7.8-brightgreen.svg) ![License MIT](https://img.shields.io/badge/license-MIT-blue.svg)

#Modifications

To make Jason's nginx-proxy more configurable without having to provide custom configs/includes, I added some env vars. All of them change the global behavior of nginx or it's configured servers within the templating engine (starting with "GLOB_"). 

Another aim is to increase performance especially in multiple full ssl based environments.

Last but not least I tried to improve readability and documentation for easier understanding of the image's working principle.

Many thanks to Jason for this and lots of other great images.

## GLOB_SSL_CERT_BUNDLE_ENABLED
To ensure CA-chain reliability, some certificate providers deliver some kind of intermediate certificate to guarantee their authority. For nginx this cert and your own cert have to be concatenated to a bundle. 

If enabled you should provide that concatenated certificate additionally to your cert, marked by some kind of insertion between original file (i.e. domain) name.

e.g. domain.org.crt -> domain.org.bundle.crt 

See the [nginx docs](http://nginx.org/en/docs/http/configuring_https_servers.html#chains) for further information.

Default: false

## GLOB_SSL_CERT_BUNDLE_INFIX

Set the insertion string inspected between name and cert file extension. Defaults to ".bundle".

## GLOB_SSL_SESSION_TIMEOUT

Change ssl session timeout - default: 5m

## GLOB_SSL_SESSION_CACHE

Modify size of shared ssl session cache - default: 50m

## GLOB_SPDY_ENABLED

Enable high speed ssl spdy protocol for supporting clients - default: false

## GLOB_HTTP_NO_SERVICE

You may want to return another status code in case of not matching server requests - default: 503

## GLOB_AUTO_REDIRECT_WITH_PREFIX_ENABLED

To easily tell the proxy to redirect requests from a prefixed domain to the none prefixed one and vice versa - default: false

## GLOB_AUTO_REDIRECT_PREFIX

Provide a custom prefix to include with auto redirect.

e.g. redirect 

*www*.domain.org -> domain.org
domain.org -> *www*.domain.org

*api*.domain.org -> domain.org
domain.org -> *cdn*.domain.org

Default: www

## GLOB_AUTO_REDIRECT_DIRECTION

To control source and destination of auto redirect:

- 0: redirect from prefix to non-prefix
- 1: redirect from non-prefix to prefix

#Original 

Find original readme data at Jason's [github repo](https://github.com/jwilder/nginx-proxy).

Focus on explaining differences here. Don't hesitate to ask.

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
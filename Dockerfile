FROM jwilder/nginx-proxy
RUN { \
      echo 'client_max_body_size 1000m;'; \
    } > /etc/nginx/conf.d/increase_proxy.conf

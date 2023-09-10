---
title: Nginx docs
weight: 100
menu:
  notes:
    name: nginx
    identifier: notes-docs-nginx
    parent: notes-docs
    weight: 10
---

{{< note title="map" >}}

```nginx
# map
map $remote_addr $limit_key {
    35.229.201.209 "";
    default $binary_remote_addr;
}
# wss.conf
limit_req_zone $limit_key zone=websocket:10m rate=20r/s;
limit_req_status 499;

server {
    location = / {
        limit_req zone=websocket nodelay;
        limit_req_log_level warn;
    }
}
```

{{< /note >}}

{{< note title="rewrite" >}}

###### 1

```nginx
# https://localhost/img/nginx.svg can access /data/nginxconfig.io/src/static/nginx.svg
location /img {
    rewrite '^/img/(.*)$' /static/$1;
  }

location /static {
    root /data/nginxconfig.io/src;
    index nginx.svg;
}

```

###### 2

```nginx
# https://localhost/photo/nginx.svg can access /data/nginxconfig.io/src/static/nginx.svg

location /photo {
    root /data/nginxconfig.io/src;
    try_files $uri /$uri @pic;
}

location @pic {
    rewrite '^/photo/(.*)$' /static/$1;
}
```

###### 3

```nginx
# remove prefix path and allow proxy_pass POST
location /upload/ {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    root /data/nginx/html;
    # Remove path
    rewrite ^/upload/(.*) /$1  break;
    proxy_pass https://logo$uri$is_args$args;
    # Proxy_pass POST
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection 'upgrade';
    proxy_cache_bypass $http_upgrade;
    #proxy_redirect  https://logo/ /;
}

location / {
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    root /data/nginx/html;
    index  index.html index.htm;
}
```

{{< /note >}}

{{< note title="grafana behind nginx" >}}

###### server/ssl.conf

```nginx
ssl_certificate     /etc/ssl/go2cloudten.com.crt;
ssl_certificate_key /etc/ssl/go2cloudten.com.key;
ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:HIGH:!RC2:!RC4:!aNULL:!eNULL:!LOW:!IDEA:!DES:!TDES:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!EXPORT:!ANON";
ssl_prefer_server_ciphers on;
ssl_protocols TLSv1.2 TLSv1.3;
ssl_session_timeout 50m;
```

###### server/proxy.conf

```nginx
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
```

###### grafana.conf

```nginx
server {
    listen       443 ssl;
    server_name  grafana-test.go2cloudten.com;
    server_name  grafana.go2cloudten.com;
    include server/ssl.conf;
    include server/proxy.conf;
    access_log  logs/grafana.log json;
    error_log   logs/grafana.error.log warn;
    location / {
        proxy_pass   http://grafana;
        proxy_connect_timeout 300;
        proxy_read_timeout 700;
        proxy_send_timeout 700;
        proxy_set_header Host $host;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
```

{{< /note >}}

---
title: "NGINX Native ACME Support: Rethinking TLS Automation from the Ground Up"
date: 2025-10-20T16:31:00+08:00
menu:
  sidebar:
    name: "NGINX Native ACME Support: Rethinking TLS Automation from the Ground Up"
    identifier: nginx-acme-module
    weight: 10
tags: ["Links", "Nginx", "ACME", "module"]
categories: ["Links", "Nginx", "ACME", "module"]
hero: images/hero/nginx.jpeg
---

- [NGINX Native ACME Support: Rethinking TLS Automation from the Ground Up](https://sconts.com/post/nginx-native-acme-support/)

## `ngx_http_acme_module`

- NGINX 1.25.1

## Pre-install

```bash
# Install build tools and NGINX dependencies on Debian/Ubuntu
sudo apt update
sudo apt install build-essential libpcre3-dev zlib1g-dev libssl-dev pkg-config libclang-dev git -y

# Install the Rust toolchain (cargo and rustc)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

mkdir -pv /app/nginx/{logs,conf,cache, acme} /app/nginx-build
cd /app/nginx-build

# Clone the ACME module source
git clone https://github.com/nginx/nginx-acme.git /app/nginx-build/nginx-acme
# Or
# git clone git@github.com:nginx/nginx-acme.git /app/nginx-build/nginx-acme

# Download the NGINX source (replace with the version you need)
wget https://nginx.org/download/nginx-1.28.0.tar.gz
tar -zxf nginx-1.28.0.tar.gz
```

## Compile

```bash
cd nginx-1.28.0
./configure \
    --prefix=/app/nginx \
    --error-log-path=/app/nginx/error.log \
    --http-log-path=/app/nginx/access.log \
    --pid-path=/app/nginx/nginx.pid \
    --lock-path=/app/nginx/nginx.lock \
    --http-client-body-temp-path=/app/nginx/cache/client_temp \
    --http-proxy-temp-path=/app/nginx/cache/proxy_temp \
    --http-fastcgi-temp-path=/app/nginx/cache/fastcgi_temp \
    --http-uwsgi-temp-path=/app/nginx/cache/uwsgi_temp \
    --http-scgi-temp-path=/app/nginx/cache/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-compat \
    --with-file-aio \
    --with-threads \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_realip_module \
    --with-stream_ssl_module \
    --with-stream_ssl_preread_module \
    --with-cc-opt='-g -O2 -ffile-prefix-map=/home/builder/debuild/nginx-1.28.0/debian/debuild-base/nginx-1.28.0=. -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -fPIC' \
    --with-ld-opt='-Wl,-z,relro -Wl,-z,now -Wl,--as-needed -pie' \
    --add-dynamic-module=/app/nginx-build/nginx-acme

make && \
    make modules && \
    make install

# Run the configure script; the key is --add-dynamic-module
# Note: include all existing NGINX build flags; see nginx -V
# Build the module; note it is make modules, not make install
```

## Config

```nginx
# /app/nginx/conf/nginx.conf
user nginx;
error_log  error.log  debug;
pid        nginx.pid;

load_module modules/ngx_http_acme_module.so;

events {
    worker_connections  1024;
    multi_accept on;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    log_format  main  '$remote_addr - $remote_user [$time_local] "$host" "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  access.log  main;
    sendfile       on;
    tcp_nopush     on;
    charset utf-8;
    keepalive_timeout  65;
    gzip  on;

    resolver 8.8.8.8 1.1.1.1;
    # Define an ACME issuer instance named letsencrypt
    acme_issuer letsencrypt {
        # Set the ACME directory URL; this is Let's Encrypt production
        uri         https://acme-v02.api.letsencrypt.org/directory;
        # Provide a contact email for CA notices (e.g., expiration)
        contact     mailto:security-alerts@aidig.co;
        # State file path for ACME account key material
        state_path  acme/letsencrypt;
        # Accept the terms of service; required for Let's Encrypt
        accept_terms_of_service;
    }
    # Optional acme_shared_zone stores certs, keys, and challenges for issuers.
    # Default size is 256K; increase as needed.
    acme_shared_zone zone=acme_shared:1M;

    server {
        listen 443 ssl;
        server_name ssl.aidig.co;

        # Step 1: enable ACME for this server and select the letsencrypt issuer
        acme_certificate    letsencrypt;
        # Step 2: use dynamic variables managed in memory by the ACME module
        ssl_certificate     $acme_certificate;
        ssl_certificate_key   $acme_certificate_key;
        ssl_certificate_cache   max=2;  # required ngx 1.27.4+

        location / {
            default_type text/plain;
            return 200 'OK';
        }
    }

    server {
        listen 80 default_server;
        server_name _;

        # ACME handles /.well-known/acme-challenge/ automatically; this is for all other requests
        location / {
            return 301 https://$host$request_uri;
        }
    }
}
```

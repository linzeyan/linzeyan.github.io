---
title: "NGINX 原生 ACME 支持：从根本上重塑 TLS 自动化部署"
date: 2025-10-20T16:31:00+08:00
menu:
  sidebar:
    name: "NGINX 原生 ACME 支持：从根本上重塑 TLS 自动化部署"
    identifier: nginx-acme-module
    weight: 10
tags: ["URL", "NGINX", "ACME", "module"]
categories: ["URL", "NGINX", "ACME", "module"]
---

[NGINX 原生 ACME 支持：从根本上重塑 TLS 自动化部署](https://sconts.com/post/nginx-native-acme-support/)

## `ngx_http_acme_module`
- NGINX 1.25.1

## pre-install
```bash
# 在 Debian/Ubuntu 系统上安装基础编译工具和 NGINX 依赖
sudo apt update
sudo apt install build-essential libpcre3-dev zlib1g-dev libssl-dev pkg-config libclang-dev git -y

# 安装 Rust 工具链 (cargo 和 rustc)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env

mkdir -pv /app/nginx/{logs,conf,cache, acme} /app/nginx-build
cd /app/nginx-build

# 克隆 ACME 模块的源码
git clone https://github.com/nginx/nginx-acme.git /app/nginx-build/nginx-acme
# 或者
# git clone git@github.com:nginx/nginx-acme.git /app/nginx-build/nginx-acme

# 下载 NGINX 源码（请替换为您需要的版本）
wget https://nginx.org/download/nginx-1.28.0.tar.gz
tar -zxf nginx-1.28.0.tar.gz
```

## compile

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

# 运行配置脚本，这里的关键是 --add-dynamic-module
# 注意：您需要在这里包含您当前 NGINX 已有的所有编译参数，可以通过 nginx -V 查看
# 编译模块，注意是 make modules 而不是 make install
```

## config

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
    # 定义一个名为 letsencrypt 的 ACME 颁发机构实例
    acme_issuer letsencrypt {
        # 指定 ACME 服务提供商的目录 URL，这里是 Let's Encrypt 的生产环境
        uri         https://acme-v02.api.letsencrypt.org/directory;
        # 提供一个联系邮箱，用于接收 CA 的重要通知（如证书即将过期）
        contact     mailto:security-alerts@aidig.co;
        # 指定状态文件的存储路径，用于保存 ACME 账户密钥，非常重要
        state_path  acme/letsencrypt;
        # 同意服务条款，对于 Let's Encrypt 等 CA 这是必需的步骤
        accept_terms_of_service;
    }
    # 可选指令 acme_shared_zone，用于存储所有配置的证书颁发者的证书、私钥和挑战数据。该区域默认大小为 256K，可根据需要增加
    acme_shared_zone zone=acme_shared:1M;

    server {
        listen 443 ssl;
        server_name ssl.aidig.co;

        # 步骤一：声明此 server 块启用 ACME，并指定使用上面定义的 letsencrypt 颁发机构
        acme_certificate    letsencrypt;
        # 步骤二：使用动态变量加载由 ACME 模块在内存中管理的证书和私钥
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

        # ACME 模块会自动处理 /.well-known/acme-challenge/ 的请求，此 location 用于处理所有其他请求
        location / {
            return 301 https://$host$request_uri;
        }
    }
}
```
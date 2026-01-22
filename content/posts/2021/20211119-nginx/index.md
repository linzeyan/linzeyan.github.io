---
title: "Nginx notes"
date: 2021-11-19T14:35:58+08:00
description: Notes about Nginx configs
menu:
  sidebar:
    name: Nginx notes
    identifier: nginx-config-notes
    weight: 10
tags: ["Nginx", "config"]
categories: ["Nginx"]
hero: images/hero/nginx.jpeg
---

# Record Nginx configuration file and explanation.

## files structure

```bash
.
├── geoip.conf
├── nginx.conf
├── sites-available
│   ├── default.conf
├── sites-enabled
│   ├── default.conf -> ../sites-available/default.conf
├── upstream.conf
```

### geoip.conf

```nginx
## module: ngx_http_geoip2_module
## https://github.com/leev/ngx_http_geoip2_module
## Read the GeoIP database and set variables
geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
    auto_reload 60m;
    $geoip2_metadata_country_build metadata build_epoch;
    ## Set $geoip2_data_country_code to the ISO 3116 country code for $remote_addr
    $geoip2_data_country_code source=$remote_addr country iso_code;
    ## Set $geoip2_data_country_name to the corresponding English city name
    $geoip2_data_country_name country names en;
}
```

### upstream.conf

```nginx
## module: ngx_http_upstream_module
## Define server groups
upstream to_nodejs1 {
    ## server address [parameters]; define a server
    ## parameters:
    ## weight=number defines the weight, default is 1
    ## max_fails=number sets max retries to the upstream server, default is 1
    ## fail_timeout=time sets the time to stop sending requests to this upstream server after reaching max_fails, default is 10 seconds
    ## backup marks this upstream server as a backup when others are unavailable
    ## down marks this upstream server as unavailable
    server 10.7.0.12:9000 max_fails=3 fail_timeout=5s;
    server 10.7.0.12:9001 max_fails=3 fail_timeout=5s backup;
}

upstream to_nodejs2 {
    server 10.7.0.12:9002 max_fails=3 fail_timeout=5s;
    server 10.7.0.12:9003 max_fails=3 fail_timeout=5s backup;
}

upstream to_nodejs9005 {
    server 10.7.0.12:9005 max_fails=3 fail_timeout=5s;
}

## module: ngx_http_map_module
## map string $variable { ... } creates a new variable
map $arg_agent $game_api {
    ## $arg_agent is the agent value in the request (https://abc.com/?agent=123)
    ## When agent=123, $game_api is to_nodejs95
    123 to_nodejs95;
    ## If agent ends with 1, 2, 3, or 4, $game_api is to_nodejs1
    ~*1$ to_nodejs1;
    ~*2$ to_nodejs1;
    ~*3$ to_nodejs1;
    ~*4$ to_nodejs1;
    ## If agent does not match the rules above, $game_api defaults to to_nodejs2
    default to_nodejs2;
}
```

### default.conf

```nginx
## module: ngx_http_limit_req_module
## Limit request handling
## limit_req_zone key zone=name:size rate=rate [sync]; defines request limiting rules
limit_req_zone $binary_remote_addr$server_name zone=websocket:10m rate=1r/m;
## limit_req_status code; sets HTTP status code for rejected connections, default is 503
limit_req_status 502;

## Configure virtual host
server {
    ## listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
    ## Set the listen port, default is *:80
    ## Below listens on port 80 and is the default virtual host
    listen 80 default_server;
    ## server_name name ...; set virtual host name, regex allowed, default is ""
    server_name  _;

    access_log  logs/default/default.log json;
    error_log   logs/default/default.error.log warn;

    ## module: ngx_http_access_module
    ## allow address | CIDR | unix: | all; allow IP access
    allow 1.1.1.1;
    ## deny address | CIDR | unix: | all; deny IP access
    deny 12.34.56.78;

    ## Set the root directory for requests
    root /usr/share/nginx/html;
    ## limit_req zone=name [burst=number] [nodelay | delay=number]; set request limiting zone
    limit_req zone=websocket nodelay;
    ## limit_req_log_level info | notice | warn | error; set log level for rejected requests, default is error
    limit_req_log_level warn;

    ## location [ = | ~ | ~* | ^~ ] uri { ... }
    ## location @name { ... } configure based on the request URI
    location / {
        default_type application/json;
        ## Return HTTP status code 200 with a string
        return 200 '{"Code": "$status", "IP": "$remote_addr"}';
    }
}


server {
    ## Below listens on port 443 and is the default virtual host; all connections use SSL
    listen 443 default_server ssl;
    server_name  _;

    access_log  logs/default/default.log json;
    error_log   logs/default/default.error.log warn;
    ## module: ngx_http_ssl_module
    ## Set the PEM-format certificate
    ssl_certificate     /etc/ssl/hddv1.com.crt;
    ## Set the PEM-format key
    ssl_certificate_key /etc/ssl/hddv1.com.key;
    ## Set SSL versions, default is TLSv1 TLSv1.1 TLSv1.2
    ssl_protocols TLSv1.2 TLSv1.3;
    ## Set enabled ciphers, default is HIGH:!aNULL:!MD5
    ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:HIGH:!RC2:!RC4:!aNULL:!eNULL:!LOW:!IDEA:!DES:!TDES:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!EXPORT:!ANON";
    ## Specify the DH parameter file for DHE ciphers
    ssl_dhparam /etc/ssl/dhparams.pem;
    ## Prefer server ciphers, default is off
    ssl_prefer_server_ciphers on;
    ## ssl_session_cache off | none | [builtin[:size]] [shared:name:size];
    ## Set cache and size, default is none
    ssl_session_cache shared:SSL:1m;
    ## Set session reuse time, default is 5 minutes
    ssl_session_timeout  5m;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

    root /usr/share/nginx/html;
    limit_req zone=websocket nodelay;
    limit_req_log_level warn;
    default_type application/json;

    location / {
        default_type application/json;
        return 200 '{"Code": "$status", "IP": "$remote_addr"}';
    }
}
```

### nginx.conf

```nginx
## module: ngx_core_module
## worker_processes number | auto; number of Nginx worker processes, auto equals CPU count
worker_processes auto;
## worker_rlimit_nofile number; max open files for workers, default is system RLIMIT_NOFILE
worker_rlimit_nofile 131072;
## worker_shutdown_timeout time; shutdown timeout for reloads and related commands
worker_shutdown_timeout 60;

## error_log file [level]; set error log path
## debug, info, notice, warn, error, crit, alert, emerg
error_log logs/error.log warn;

## pid file; master process ID file location
pid logs/nginx.pid;

## module: ngx_core_module
## Connection handling
events {
    ## worker_connections number; max concurrent connections per worker, default is 512, must be less than worker_rlimit_nofile
    ## max connections = worker_connections * worker_processes
    worker_connections 102400;

    ## accept_mutex on | off; default is off
    ## When on, only one worker accepts new connections while others remain idle
    ## When off, all workers wake up; one accepts, the rest go back to sleep
    ## With TCP long connections and high traffic, off performs better for throughput and QPS
    accept_mutex off;

    ## multi_accept on | off; accept all connections at once, default is off
    multi_accept on;
}

## module: ngx_http_core_module
## HTTP server settings
http {
    ## module: ngx_core_module
    ## include file | mask; include settings from file
    ## Below sets MIME types, defined in the mime.type file
    include mime.types;

    ## default_type mime-type; default MIME type, default is text/plain
    default_type application/octet-stream;
    ## server_names_hash_max_size size; max size of the server_name hash table, default is 512k
    server_names_hash_max_size 2048;
    ## Size of the server_name hash table for fast lookup, default depends on CPU L1 cache
    server_names_hash_bucket_size 256;
    ## server_tokens on | off | build | string; show Nginx version on error pages, default is on
    server_tokens off;
    ## Log 404 in the error log
    log_not_found off;
    ## Enable sendfile() for file transfer efficiency, default is off
    sendfile on;
    ## Use full packets for file sending, default is off
    tcp_nopush on;
    ## Send data as soon as possible, default is on
    tcp_nodelay on;
    ## Set keepalive timeout seconds; Nginx closes after timeout, default is 75
    keepalive_timeout 70;
    ## client_max_body_size size; max allowed request body size
    client_max_body_size 64M;

    ## module: ngx_http_gzip_module
    ## Enable gzip compression, default is off
    gzip on;
    ## Minimum Content-Length to gzip, default is 20
    gzip_min_length 1k;
    ## Gzip buffer size, default is one memory page
    ## gzip_buffers number size;
    gzip_buffers 4 32k;
    ## Compression level, range 1-9, default is 1
    gzip_comp_level 7;
    ## MIME types to compress, default is text/html
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/x-httpd-php application/json;
    ## Add Vary: Accept-Encoding to HTTP response headers, default is off
    gzip_vary on;
    ## Disable compression for specific User-Agent
    ## Below disables IE 6
    gzip_disable "MSIE [1-6]\.";

    ## resolver address ... [valid=time] [ipv6=on|off] [status_zone=zone]; use the specified DNS servers for server_name and upstreams
    resolver 114.114.114.114 8.8.8.8 1.1.1.1;

    ## module: ngx_http_headers_module
    ## add_header name value [always]; add fields to HTTP response headers
    ## Below allows CORS
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Headers DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type;
    add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
    add_header Access-Control-Expose-Headers 'WWW-Authenticate,Server-Authorization,User-Identity-Token';

    ## module: ngx_http_realip_module
    ## set_real_ip_from address | CIDR | unix:; set trusted proxy IPs such as reverse proxies
    set_real_ip_from 10.0.0.0/8;
    set_real_ip_from 172.16.0.0/12;
    set_real_ip_from 192.168.0.0/16;
    ## real_ip_header field | X-Real-IP | X-Forwarded-For | proxy_protocol; define which header provides client IP, default is X-Real-IP
    real_ip_header X-Forwarded-For;
    ## Use the last non-trusted IP or last IP in real_ip_header as the real IP, default is off
    real_ip_recursive on;

    ## module: ngx_http_log_module
    ## log_format name [escape=default|json|none] string ...; set log format
    log_format json escape=json '{"@timestamp":"$time_iso8601",'
        '"@source":"$server_addr",'
        '"ip":"$http_x_forwarded_for",'
        '"client":"$remote_addr",'
        '"request_method":"$request_method",'
        '"scheme":"$scheme",'
        '"domain":"$server_name",'
        '"client_host":"$host",'
        '"referer":"$http_referer",'
        '"request":"$request_uri",'
        '"args":"$args",'
        '"sent_bytes":$body_bytes_sent,'
        '"status":$status,'
        '"responsetime":$request_time,'
        '"upstreamtime":"$upstream_response_time",'
        '"upstreamaddr":"$upstream_addr",'
        '"http_user_agent":"$http_user_agent",'
        '"Country":"$geoip2_data_country_name",'
        '"State":"$geoip2_data_state_name",'
        '"City":"$geoip2_data_city_name",'
        '"https":"$https"'
        '}';
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
    '$status $body_bytes_sent "$http_referer" '
    '"$http_user_agent" "$http_x_forwarded_for"';
    ## access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]]; set log path and format name
    ## access_log off; disable logging
    access_log logs/access.log json;
}
```

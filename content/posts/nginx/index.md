---
title: "Nginx notes"
date: 2021-11-19T14:35:58+08:00
description: Notes about Nginx configs
menu:
  sidebar:
    name: Nginx
    identifier: nginx
    weight: 10
tags: ["Nginx", "configs"]
categories: ["Nginx"]
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
## 讀取 GeoIP 資料庫，並進行變數設定
geoip2 /usr/share/GeoIP/GeoLite2-Country.mmdb {
    auto_reload 60m;
    $geoip2_metadata_country_build metadata build_epoch;
    ## 自定義 $geoip2_data_country_code 值為 $remote_addr 對應的 ISO 3116 規範的國碼
    $geoip2_data_country_code source=$remote_addr country iso_code;
    ## 自定義 $geoip2_data_country_name 值為對應的英文城市名
    $geoip2_data_country_name country names en;
}
```

### upstream.conf

```nginx
## module: ngx_http_upstream_module
## 定義 server 組別
upstream to_nodejs1 {
    ## server address [parameters]; 定義 server
    ## parameters:
    ## weight=number 定義權重，預設為 1
    ## max_fails=number 設定到 upstream server 的最大重試次數，預設為 1
    ## fail_timeout=time 設定到達 max_fails 次數之後，暫停向此 upstream server 傳送請求的時間，預設為 10 秒
    ## backup 標記此 upstream server 為備用，當其他 upstream server 不可用時，此 upstream server 可接受請求
    ## down 標記此 upstream server 為不可用
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
## map string $variable { ... } 建立一個新的變數
map $arg_agent $game_api {
    ## $arg_agent 請求中 agent 的值(https://abc.com/?agent=123)
    ## agent=123, $game_api 的值為 to_nodejs95
    123 to_nodejs95;
    ## agent 結尾是 1, 2, 3, 或是 4, $game_api 的值為 to_nodejs1
    ~*1$ to_nodejs1;
    ~*2$ to_nodejs1;
    ~*3$ to_nodejs1;
    ~*4$ to_nodejs1;
    ## 若 agent 不符合上開規則，預設 $game_api 的值為 to_nodejs2
    default to_nodejs2;
}
```

### default.conf

```nginx
## module: ngx_http_limit_req_module
## 限制請求處理
## limit_req_zone key zone=name:size rate=rate [sync]; 定義限制請求的規則
limit_req_zone $binary_remote_addr$server_name zone=websocket:10m rate=1r/m;
## limit_req_status code; 設定被拒絕連線的 HTTP 狀態碼，預設為 503
limit_req_status 502;

## 設定虛擬主機
server {
    ## listen port [default_server] [ssl] [http2 | spdy] [proxy_protocol] [setfib=number] [fastopen=number] [backlog=number] [rcvbuf=size] [sndbuf=size] [accept_filter=filter] [deferred] [bind] [ipv6only=on|off] [reuseport] [so_keepalive=on|off|[keepidle]:[keepintvl]:[keepcnt]];
    ## 設定監聽的埠口，預設為 *:80
    ## 下方設定為監聽 80 port，且為預設的虛擬主機
    listen 80 default_server;
    ## server_name name ...; 設定虛擬主機名，可使用正則表示式，預設為 ""
    server_name  _;

    access_log  logs/default/default.log json;
    error_log   logs/default/default.error.log warn;

    ## module: ngx_http_access_module
    ## allow address | CIDR | unix: | all; 允許 IP 訪問
    allow 1.1.1.1;
    ## deny address | CIDR | unix: | all; 禁止 IP 訪問
    deny 12.34.56.78;

    ## 設定請求訪問的根資料夾
    root /usr/share/nginx/html;
    ## limit_req zone=name [burst=number] [nodelay | delay=number]; 設定限制請求的規則 zone
    limit_req zone=websocket nodelay;
    ## limit_req_log_level info | notice | warn | error; 設定被拒絕連線的請求日誌等級，預設為 error
    limit_req_log_level warn;

    ## location [ = | ~ | ~* | ^~ ] uri { ... }
    ## location @name { ... } 依據請求的 URI 配置
    location / {
        default_type application/json;
        ## 返回 HTTP 狀態碼 200，並包含字串
        return 200 '{"Code": "$status", "IP": "$remote_addr"}';
    }
}


server {
    ## 下方設定為監聽 443 port，且為預設的虛擬主機，所有連線都使用 SSL
    listen 443 default_server ssl;
    server_name  _;

    access_log  logs/default/default.log json;
    error_log   logs/default/default.error.log warn;
    ## module: ngx_http_ssl_module
    ## 設定 PEM 格式的證書
    ssl_certificate     /etc/ssl/hddv1.com.crt;
    ## 設定 PEM 格式的密鑰
    ssl_certificate_key /etc/ssl/hddv1.com.key;
    ## 設定 SSL 版本，預設為 TLSv1 TLSv1.1 TLSv1.2
    ssl_protocols TLSv1.2 TLSv1.3;
    ## 設定啟用的加密方法，預設為 HIGH:!aNULL:!MD5
    ssl_ciphers "EECDH+ECDSA+AESGCM:EECDH+aRSA+AESGCM:EECDH+ECDSA+SHA384:EECDH+ECDSA+SHA256:EECDH+aRSA+SHA384:EECDH+aRSA+SHA256:EECDH+aRSA+RC4:EECDH:EDH+aRSA:HIGH:!RC2:!RC4:!aNULL:!eNULL:!LOW:!IDEA:!DES:!TDES:!3DES:!MD5:!EXP:!PSK:!SRP:!DSS:!EXPORT:!ANON";
    ## 為 DHE 加密法指定帶有 DH 參數的文件
    ssl_dhparam /etc/ssl/dhparams.pem;
    ## 是否優先使用 server 的加密法，預設為 off
    ssl_prefer_server_ciphers on;
    ## ssl_session_cache off | none | [builtin[:size]] [shared:name:size];
    ## 設定緩存及大小，預設為 none
    ssl_session_cache shared:SSL:1m;
    ## 設定 session 可重複使用的時間，預設為 5 分鐘
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
## worker_processes number | auto; 啟動 Nginx worker 程序數量, 設定 auto 即和 CPU 的數量相等
worker_processes auto;
## worker_rlimit_nofile number; Nginx worker 程序最大打開文件數，預設為系統 RLIMIT_NOFILE
worker_rlimit_nofile 131072;
## worker_shutdown_timeout time; 設定關閉超時時間，當執行 reload 或是其他相關指令，超過 time 時間之後，Nginx 會主動關閉所有受影響的 worker
worker_shutdown_timeout 60;

## error_log file [level]; 設定錯誤日誌寫入位置
## debug, info, notice, warn, error, crit, alert, emerg
error_log logs/error.log warn;

## pid file; 主程序 ID 文件位置
pid logs/nginx.pid;

## module: ngx_core_module
## 設定連線處理相關
events {
    ## worker_connections number; 單個 Nginx worker 程序的最大並發連接數，預設為 512，需要小於 worker_rlimit_nofile
    ## 最大連接數 = worker_connections * worker_processes
    worker_connections 102400;

    ## accept_mutex on | off; 預設為 off
    ## 只有一個新連線進入，如果設定為 on，只有一個 worker 會接受連線，其餘持續休眠
    ## 如果設定為 off，所有 worker 會被喚醒，只有一個 worker 會接受連線，其餘重新休眠
    ## 業務上使用 TCP 長連線、流量大，off 的效能以及 QPS 表現較佳
    accept_mutex off;

    ## multi_accept on | off; 是否同時接受所有的請求，預設為 off
    multi_accept on;
}

## module: ngx_http_core_module
## 設定 HTTP server 相關
http {
    ## module: ngx_core_module
    ## include file | mask; 使用文件中的設定
    ## 下方為設定 MIME 類型,類型由 mime.type 文件定義
    include mime.types;

    ## default_type mime-type; 定義默認 MIME 類型，預設為 text/plain
    default_type application/octet-stream;
    ## server_names_hash_max_size size; 設定 server_name 的 hash 表最大值，預設為 512 kb
    server_names_hash_max_size 2048;
    ## 設定 server_name 的 hash 表的大小，用於快速找到對應的 server_name，預設值取決於 CPU 的 L1 cache
    server_names_hash_bucket_size 256;
    ## server_tokens on | off | build | string; 是否在 Nginx 錯誤頁面顯示 Nginx 版本，預設為 on
    server_tokens off;
    ## 是否在錯誤日誌記錄 404
    log_not_found off;
    ## 是否啟用 sendfile() 提高文件傳輸效率，預設為 off
    sendfile on;
    ## 文件是否使用完整封包發送，預設為 off
    tcp_nopush on;
    ## 數據是否儘快傳送，預設為 on
    tcp_nodelay on;
    ## 設定長連線持續秒數，超過時間 Nginx 會主動關閉連線，預設為 75
    keepalive_timeout 70;
    ## client_max_body_size size; 設定請求允許最大的 body 大小
    client_max_body_size 64M;

    ## module: ngx_http_gzip_module
    ## 是否啟用 gzip 壓縮，預設為 off
    gzip on;
    ## 設定要壓縮的 Content-Length 最小值，預設為 20
    gzip_min_length 1k;
    ## 設定壓縮緩衝大小，預設為一頁記憶體
    ## gzip_buffers number size;
    gzip_buffers 4 32k;
    ## 設定壓縮等級，範圍 1 ~ 9，預設為 1
    gzip_comp_level 7;
    ## 設定要壓縮的 MIME 類型，預設為 text/html
    gzip_types text/plain application/x-javascript text/css application/xml text/javascript application/x-httpd-php application/json;
    ## 是否在 HTTP response header 增加 Vary: Accept-Encoding，預設為 off
    gzip_vary on;
    ## 針對特定 User-Agent 禁用壓縮
    ## 下方為設定禁用 IE 6
    gzip_disable "MSIE [1-6]\.";

    ## resolver address ... [valid=time] [ipv6=on|off] [status_zone=zone]; 使用指定的 NS 解析 server_name, upstream server 等
    resolver 114.114.114.114 8.8.8.8 1.1.1.1;

    ## module: ngx_http_headers_module
    ## add_header name value [always]; 在 HTTP response header 增加欄位
    ## 下方為設定允許跨域
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Headers DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type;
    add_header Access-Control-Allow-Methods GET,POST,OPTIONS;
    add_header Access-Control-Expose-Headers 'WWW-Authenticate,Server-Authorization,User-Identity-Token';

    ## module: ngx_http_realip_module
    ## set_real_ip_from address | CIDR | unix:; 設定信任的可被替代的伺服器 IP，如反向代理伺服器
    set_real_ip_from 10.0.0.0/8;
    set_real_ip_from 172.16.0.0/12;
    set_real_ip_from 192.168.0.0/16;
    ## real_ip_header field | X-Real-IP | X-Forwarded-For | proxy_protocol; 定義使用哪個標頭取代獲取到的 client IP，預設為 X-Real-IP
    real_ip_header X-Forwarded-For;
    ## 將 real_ip_header 設定的標頭中，「最後一個非信任伺服器 IP」或是「最後一個 IP」當成真實 IP，預設為 off
    real_ip_recursive on;

    ## module: ngx_http_log_module
    ## log_format name [escape=default|json|none] string ...; 設定日誌格式
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
    ## access_log path [format [buffer=size] [gzip[=level]] [flush=time] [if=condition]]; 設定日誌寫入位置以及使用的日誌名稱
    ## access_log off; 不紀錄日誌
    access_log logs/access.log json;
}
```
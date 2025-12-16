---
title: Server-Configs Notes
menu:
  notes:
    name: Server-Configs
    identifier: notes-server-configs
    weight: 20
---

{{< note title="Kafka" >}}

###### consumer.properties

```ini
max.partition.fetch.bytes=104857600
```

###### server.properties

```ini
socket.send.buffer.bytes=1048576000
socket.receive.buffer.bytes=1048576000
log.retention.bytes=-1
group.initial.rebalance.delay.ms=0
max.message.bytes=1048576000
fetch.message.max.bytes=1048576000
replica.fetch.max.bytes=1048576000
socket.request.max.bytes=1048576000
# 单个索引文件最大 10 MB
log.index.size.max.bytes=10485760
# 日志段大小 512 MB（根据需要再调小）
log.segment.bytes=536870912
# 避免過多 client 連進來撐爆 broker
max.connections=50000
max.connections.per.ip=20000
# 逾時
connections.max.idle.ms=300000
request.timeout.ms=60000

# —— 高并发优化配置 ——
# 若需要更高吞吐、能接受更高的调度开销
# num.network.threads=2    # 网络线程数 → CPU 核心数
# num.io.threads=4         # I/O 线程数 → 核心数×2
# 一般num.network.threads主要处理网络io，读写缓冲区数据，基本没有io等待，配置线程数量为cpu核数加1
# num.io.threads主要进行磁盘io操作，高峰期可能有些io等待，因此配置需要大些。配置线程数量为cpu核数2倍，最大不超过3倍.
```

{{< /note >}}

{{< note title="Matomo" >}}

###### nginx.conf
```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
	# multi_accept on;
}

http {

	##
	# Basic Settings
	##

	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	server_tokens off;
	# 同時調高打開的檔案數
        open_file_cache   max=1000 inactive=20s;
        open_file_cache_valid 30s;
        open_file_cache_min_uses 2;

	# server_names_hash_bucket_size 64;
	# server_name_in_redirect off;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	##
	# SSL Settings
	##

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	##
	# Logging Settings
	##

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	##
	# Gzip Settings
	##

	gzip on;
        gzip_min_length  1024;
        gzip_comp_level  5;
        gzip_proxied     any;
        gzip_types       text/plain text/css application/javascript application/json image/svg+xml;

    # 全域 expires 規則
    expires 1d;
    add_header Cache-Control "public";

	# gzip_vary on;
	# gzip_proxied any;
	# gzip_comp_level 6;
	# gzip_buffers 16 8k;
	# gzip_http_version 1.1;
	# gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

	##
	# Virtual Host Configs
	##

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;
}
```
###### matomo.conf
```nginx
server {
    listen 80;
    server_name analytics.matomo.cc;
    root /var/www/html/matomo;

    index index.php index.html;
    access_log /var/log/nginx/matomo.access.log;
    error_log  /var/log/nginx/matomo.error.log warn;

    location / {
        try_files $uri $uri/ =404;
    }

    # Matomo Rewrite for pretty URLs
    location ~ ^/(index|piwik|matomo)\.php(/|$) {
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        include fastcgi_params;
        fastcgi_param PATH_INFO $fastcgi_path_info;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;
        # 緩衝區
        fastcgi_buffers           16 16k;
        fastcgi_buffer_size       32k;
        fastcgi_busy_buffers_size 64k;
        fastcgi_temp_file_write_size 64k;
        # 逾時
        fastcgi_read_timeout 300;
        fastcgi_connect_timeout 60;
        fastcgi_send_timeout    60;

        # 加速 HEAD 請求
        fastcgi_ignore_headers  X-Accel-Buffering;
    }

    # 靜態檔案快取
    location ~* \.(js|woff2?|ttf|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
	access_log off;
        log_not_found off;
    }

    # 安全：拒絕存取 .ht*
    location ~ /\.ht {
        deny all;
    }
}
```

###### crontab
```bash
*/5 * * * * php /var/www/html/matomo/console core:archive --force-all-websites > /var/log/matomo-archive.log 2>&1
```

{{< /note >}}

{{< note title="MySQL" >}}

```ini
# 臨時表大小 - 可以設定更大
tmp_table_size = 2147483648      # 2GB (約記憶體的3-4%)
max_heap_table_size = 2147483648 # 2GB (必須與 tmp_table_size 相同)

# 排序緩衝區 - 每個連線獨立使用
sort_buffer_size = 4194304       # 4MB (不要太大，會佔用過多記憶體)

# 讀取緩衝區
read_buffer_size = 2097152       # 2MB (你的設定已經合適)
read_rnd_buffer_size = 8388608   # 8MB (可以稍微增大)

# 連線緩衝區
join_buffer_size = 8388608       # 8MB
bulk_insert_buffer_size = 67108864 # 64MB

# InnoDB 相關
innodb_buffer_pool_size = 42949672960  # 40GB (約記憶體的60-65%)
innodb_log_file_size = 2147483648      # 2GB
innodb_log_buffer_size = 67108864      # 64MB


# 設定原則
# tmp_table_size & max_heap_table_size：
# 這兩個參數必須相同
# 建議設定為記憶體的 2-4%
# 64GB 機器建議 1-2GB

# sort_buffer_size：
# 每個連線都會分配，不要設太大
# 建議 2-8MB，你的 2MB 其實已經合適


# innodb_buffer_pool_size：
# 最重要的參數
# 建議設定為記憶體的 60-70%
# 64GB 機器建議 38-42GB

# TempTable Storage Engine 參數（MySQL 8.0 關鍵）
temptable_max_ram = 4294967296      # 4GB（記憶體中臨時表）
temptable_max_mmap = 42949672960    # 40GB（記憶體映射檔案）
temptable_use_mmap = 1              # 啟用記憶體映射
```

{{< /note >}}

{{< note title="v2ray" >}}

###### supervisord.conf
```ini
; supervisor config file

[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)

[supervisord]
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)
logfileMaxbytes=100MB
logfileBackups=50
loglevel=debug

; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket

; The [include] section can just contain the "files" setting.  This
; setting can list multiple files (separated by whitespace or
; newlines).  It can also contain wildcards.  The filenames are
; interpreted as relative to this file.  Included files *cannot*
; include files themselves.

[include]
files = /etc/supervisor/conf.d/*.conf
```

###### conf.d/v2ray.conf

```ini
[program:v2ray]
command = /etc/v2ray/bin/v2ray run -config /etc/v2ray/config.json -confdir /etc/v2ray/conf
process_name = v2ray
stdout_logfile = /var/log/supervisor/v2ray.log
stderr_logfile = /var/log/supervisor/v2ray.log
autostart=true
startsecs=3
startretries=3
autorestart=true
exitcodes=0
stopsignal=TERM
stopwaitsecs=10
stopasgroup=true
killasgroup=true

[program:caddy]
command = /usr/local/bin/caddy run --environ --config /etc/caddy/Caddyfile --adapter caddyfile
process_name = caddy
stdout_logfile = /var/log/supervisor/caddy.log
stderr_logfile = /var/log/supervisor/caddy.log
autostart=true
startsecs=3
startretries=3
autorestart=true
exitcodes=0
stopsignal=TERM
stopwaitsecs=10
stopasgroup=true
killasgroup=true
```

{{< /note >}}

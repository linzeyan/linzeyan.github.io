---
title: "Fix Nginx 500 errors (too many open files, connection)"
date: 2021-10-09T11:51:06+08:00
menu:
  sidebar:
    name: "Fix Nginx 500 errors (too many open files, connection)"
    identifier: nginx-worker-many-file-fix
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Fix Nginx 500 errors (too many open files, connection)](https://blog.longwin.com.tw/2011/05/nginx-worker-many-file-fix-2011/)

Nginx 500 errors only show up in logs. Two common cases:

### socket() failed (24: Too many open files) while connecting to upstream

```bash
$ sudo su - www-data
$ ulimit -n # check current limit (ulimit -a shows all params)
1024

# vim /etc/security/limits.conf # set nofile (max number of open files)
# add/modify the following two lines
* soft nofile 655360
* hard nofile 655360

ulimit -n # log out and log back in to see the new value
655360

# If ulimit -n is not 655360, run ulimit -n 655360 to force set it
# Then verify with ulimit -n or ulimit -Sn (soft) and ulimit -Hn (hard) (or ulimit -a).

# Calculate and set from system level
lsof | wc -l # count open files
sudo vim /etc/sysctl.conf
fs.file-max = 3268890
sudo sysctl -p
```

### 512 worker_connections are not enough while connecting to upstream

```bash
# /etc/nginx/nginx.conf
worker_connections  10240;

# Refer to Nginx CoreModule
# worker_processes 2;
# worker_rlimit_nofile 10240;
# events {
# # worker_connections 10240;
# }

# Increasing Nginx connections can slow down overall speed because php-cgi is not enough.
# Adjust as follows.

# php-cgi was started with phpfcgid_children="10" and phpfcgid_requests="500"
# ab was run on another server, connect via a switch using GBit ethernet
# http://till.klampaeckel.de/blog/archives/30-PHP-performance-III-Running-nginx.html

# vim /etc/nginx/nginx.conf
worker_connections 10240;
worker_rlimit_nofile

# vim /etc/init.d/php-fcgi
PHP_FCGI_CHILDREN=15
PHP_FCGI_MAX_REQUESTS=1000
change to
PHP_FCGI_CHILDREN=512 # or 150 and increase gradually, watch MySQL connections
PHP_FCGI_MAX_REQUESTS=10240

# The article's phpfcgid_stop() function is good and can be used if needed.
# phpfcgid_stop() {
# echo "Stopping $name."
# pids=`pgrep php-cgi`
# pkill php-cgi
# wait_for_pids $pids
# }
```

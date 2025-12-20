---
title: "Nginx 出現 500 Error 修復 (too many open file, connection)"
date: 2021-10-09T11:51:06+08:00
menu:
  sidebar:
    name: "Nginx 出現 500 Error 修復 (too many open file, connection)"
    identifier: nginx-worker-many-file-fix
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx 出現 500 Error 修復 (too many open file, connection)](https://blog.longwin.com.tw/2011/05/nginx-worker-many-file-fix-2011/)

Nginx 出現 500 Error, 錯誤訊息只能從 Log 查到, 有遇到下述兩種狀況:

### socket() failed (24: Too many open files) while connecting to upstream

```bash
$ sudo su - www-data
$ ulimit -n # 看目前系統設定的限制 (ulimit -a # 可查看全部參數)
1024

# vim /etc/security/limits.conf # 由此檔案設定 nofile (nofile - max number of open files) 的大小
# 增加/修改 下述兩行
* soft nofile 655360
* hard nofile 655360

ulimit -n # 登出後, 在登入, 執行就會出現此值
655360

# 若 ulimit -n 沒出現 655360 的話, 可使用 ulimit -n 655360 # 強制設定
# 再用 ulimit -n 或 ulimit -Sn (驗證軟式設定)、ulimit -Hn (驗證硬式設定) 檢查看看(或 ulimit -a).

# 從系統面另外計算 + 設定
lsof | wc -l # 計算開啟檔案數量
sudo vim /etc/sysctl.conf
fs.file-max = 3268890
sudo sysctl -p
```

### 512 worker_connections are not enough while connecting to upstream

```bash
# /etc/nginx/nginx.conf
worker_connections  10240;

# 參考 Nginx CoreModule
# worker_processes 2;
# worker_rlimit_nofile 10240;
# events {
# # worker_connections 10240;
# }

# Nginx 的 connection 增加後, 整體速度會變慢很多, 主要原因是 php-cgi 不夠用, 所以要作以下調整.

# php-cgi was started with phpfcgid_children="10" and phpfcgid_requests="500"
# ab was run on another server, connect via a switch using GBit ethernet
# http://till.klampaeckel.de/blog/archives/30-PHP-performance-III-Running-nginx.html

# vim /etc/nginx/nginx.conf
worker_connections 10240;
worker_rlimit_nofile

# vim /etc/init.d/php-fcgi
PHP_FCGI_CHILDREN=15
PHP_FCGI_MAX_REQUESTS=1000
改成
PHP_FCGI_CHILDREN=512 # 或 150 慢慢加, 注意 MySQL connection 是否夠用
PHP_FCGI_MAX_REQUESTS=10240

# 上述文章的 phpfcgid_stop(), 寫得還不錯, 有需要可以用看看.
# phpfcgid_stop() {
# echo "Stopping $name."
# pids=`pgrep php-cgi`
# pkill php-cgi
# wait_for_pids $pids
# }
```

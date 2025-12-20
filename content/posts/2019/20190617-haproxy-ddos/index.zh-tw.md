---
title: "設定 Haproxy 以防止 DDOS 攻擊"
date: 2019-06-17T11:07:13+08:00
menu:
  sidebar:
    name: "設定 Haproxy 以防止 DDOS 攻擊"
    identifier: haproxy-defend-ddos-configuration
    weight: 10
tags: ["URL", "HAProxy"]
categories: ["URL", "HAProxy"]
---

- [設定 Haproxy 以防止 DDOS 攻擊](https://blog.maxkit.com.tw/2016/05/haproxy-ddos.html)

### TCP syn flood attacks

```shell
vi /etc/sysctl.conf

# Protection from SYN flood
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_max_syn_backlog = 1024
```

### Slowloris like attacks

```
defaults
     option      http-server-close
     timeout     http-request 5s
     timeout     connect 5s
     timeout     client 30s
     timeout     server 10s
     timeout     tunnel 1h
```

### 限制每一個 user 的連線數量

普通用戶瀏覽網站的網頁，或是從網站下載東西時，瀏覽器一般會建立 5-7 個 TCP 鏈接。當一個惡意 client 打開了大量 TCP 連線時，耗費大量資源，因此我們必須要限制同一個用戶的連線數量。

但如果有很多使用者，是從某一個私有網段，透過 NAT 的方式連線到 Server 時，且實際上我們也不知道，到底哪一個會是 NAT 的轉址後的 IP，不知道該將哪個 IP 設定為白名單，這樣的限制就會造成問題，因此我們認為實際的環境，這樣的設定應該要保留不處理。

以下是一個設定的範例，最重要的地方是在 frontend ft_web 區塊的設定。

```
global
  stats socket ./haproxy.stats level admin

defaults
  option http-server-close
  mode http
  timeout http-request 5s
  timeout connect 5s
  timeout server 10s
  timeout client 30s

listen stats
  bind 0.0.0.0:8880
  stats enable
  stats hide-version
  stats uri     /
  stats realm   HAProxy Statistics
  stats auth    admin:admin

frontend ft_web
  bind 0.0.0.0:8080

  # Table definition
  stick-table type ip size 100k expire 30s store conn_cur

  # Allow clean known IPs to bypass the filter
  tcp-request connection accept if { src -f /etc/haproxy/whitelist.lst }
  # Shut the new connection as long as the client has already 10 opened
  tcp-request connection reject if { src_conn_cur ge 10 }
  tcp-request connection track-sc1 src

  # Split static and dynamic traffic since these requests have different impacts on the servers
  use_backend bk_web_static if { path_end .jpg .png .gif .css .js }

  default_backend bk_web

# Dynamic part of the application
backend bk_web
  balance roundrobin
  cookie MYSRV insert indirect nocache
  server srv1 192.168.1.2:80 check cookie srv1 maxconn 100
  server srv2 192.168.1.3:80 check cookie srv2 maxconn 100

# Static objects
backend bk_web_static
  balance roundrobin
  server srv1 192.168.1.2:80 check maxconn 1000
  server srv2 192.168.1.3:80 check maxconn 1000
```

### 限制每個 user 產生新連線的速率 Limiting the connection rate per user

惡意的使用者會在短時間內建立很多連線，但如果產生新連線的速度太高，就會消耗掉過多的資源服務一個使用者。

因為 browser 有可能在幾秒鐘內，建立 7 個 TCP Connection，所以基本上認定如果在 3 秒鐘內，建立了超過 20 個 TCP Connection，就有可能是惡意的 client。

但如果有很多使用者，是從某一個私有網段，透過 NAT 的方式連線到 Server 時，且實際上我們也不知道，到底哪一個會是 NAT 的轉址後的 IP，不知道該將哪個 IP 設定為白名單，這樣的限制就會造成問題，因此我們認為實際的環境，這樣的設定應該要保留不處理。

```
frontend ft_web
  bind 0.0.0.0:8080

  # Table definition
  stick-table type ip size 100k expire 30s store conn_rate(3s)

  # Allow clean known IPs to bypass the filter
  tcp-request connection accept if { src -f /etc/haproxy/whitelist.lst }
  # Shut the new connection as long as the client has already 10 opened
  # tcp-request connection reject if { src_conn_cur ge 10 }
  tcp-request connection track-sc1 src

  # Split static and dynamic traffic since these requests have different impacts on the servers
  use_backend bk_web_static if { path_end .jpg .png .gif .css .js }

  default_backend bk_web
```

### 限制產生 HTTP request 的速度 Limiting the HTTP request rate

```
global
  stats socket ./haproxy.stats level admin

defaults
  option http-server-close
  mode http
  timeout http-request 5s
  timeout connect 5s
  timeout server 10s
  timeout client 30s

listen stats
  bind 0.0.0.0:8880
  stats enable
  stats hide-version
  stats uri     /
  stats realm   HAProxy Statistics
  stats auth    admin:admin

frontend ft_web
  bind 0.0.0.0:8080

  # Use General Purpose Couter (gpc) 0 in SC1 as a global abuse counter
  # Monitors the number of request sent by an IP over a period of 10 seconds
  stick-table type ip size 1m expire 10s store gpc0,http_req_rate(10s)
  tcp-request connection track-sc1 src
  tcp-request connection reject if { src_get_gpc0 gt 0 }

  # Split static and dynamic traffic since these requests have different impacts on the servers
  use_backend bk_web_static if { path_end .jpg .png .gif .css .js }

  default_backend bk_web

# Dynamic part of the application
backend bk_web
  balance roundrobin
  cookie MYSRV insert indirect nocache

  # If the source IP sent 10 or more http request over the defined period,
  # flag the IP as abuser on the frontend
  acl abuse src_http_req_rate(ft_web) ge 10
  acl flag_abuser src_inc_gpc0(ft_web)
  tcp-request content reject if abuse flag_abuser

  server srv1 192.168.1.2:80 check cookie srv1 maxconn 100
  server srv2 192.168.1.3:80 check cookie srv2 maxconn 100

# Static objects
backend bk_web_static
  balance roundrobin
  server srv1 192.168.1.2:80 check maxconn 1000
  server srv2 192.168.1.3:80 check maxconn 1000
```

### 偵測弱點掃描 Detecting vulnerability scans

如果有人進行弱點掃描，在 Server 通常會遇到以下這些錯誤訊息：

- invalid and truncated requests
- denied or tarpitted requests
- failed authentications
- 4xx error pages

```
global
  stats socket ./haproxy.stats level admin

defaults
  option http-server-close
  mode http
  timeout http-request 5s
  timeout connect 5s
  timeout server 10s
  timeout client 30s

listen stats
  bind 0.0.0.0:8880
  stats enable
  stats hide-version
  stats uri     /
  stats realm   HAProxy Statistics
  stats auth    admin:admin

frontend ft_web
  bind 0.0.0.0:8080

  # Use General Purpose Couter 0 in SC1 as a global abuse counter
  # Monitors the number of errors generated by an IP over a period of 10 seconds
  stick-table type ip size 1m expire 10s store gpc0,http_err_rate(10s)
  tcp-request connection track-sc1 src
  tcp-request connection reject if { src_get_gpc0 gt 0 }

  # Split static and dynamic traffic since these requests have different impacts on the servers
  use_backend bk_web_static if { path_end .jpg .png .gif .css .js }

  default_backend bk_web

# Dynamic part of the application
backend bk_web
  balance roundrobin
  cookie MYSRV insert indirect nocache

  # If the source IP generated 10 or more http request over the defined period,
  # flag the IP as abuser on the frontend
  acl abuse src_http_err_rate(ft_web) ge 10
  acl flag_abuser src_inc_gpc0(ft_web)
  tcp-request content reject if abuse flag_abuser

  server srv1 192.168.1.2:80 check cookie srv1 maxconn 100
  server srv2 192.168.1.3:80 check cookie srv2 maxconn 100

# Static objects
backend bk_web_static
  balance roundrobin
  server srv1 192.168.1.2:80 check maxconn 1000
  server srv2 192.168.1.3:80 check maxconn 1000
```

---
title: "Avoiding the Top 10 NGINX Configuration Mistakes - NGINX"
date: 2022-09-16T15:22:23+08:00
menu:
  sidebar:
    name: "Avoiding the Top 10 NGINX Configuration Mistakes - NGINX"
    identifier: nginx-avoiding-top-10-nginx-configuration-mistakes
    weight: 10
tags: ["URL", "NGINX"]
categories: ["URL", "NGINX"]
hero: images/hero/nginx.jpeg
---

- [Avoiding the Top 10 NGINX Configuration Mistakes - NGINX](https://www.nginx.com/blog/avoiding-top-10-nginx-configuration-mistakes/)

## 1) 每個 worker 的檔案描述元（FD）不夠

### 問題點

- `worker_connections` 只限制 **單一 worker 可同時開啟的連線數**（預設 512）。
- 但每個連線/檔案/暫存檔/日誌都會消耗 **檔案描述元（FD）**，而 OS 預設每個 process 常見是 1024。
- 常見錯誤：只調大 `worker_connections`，卻沒有同步提高 FD 限制，導致 worker 提早耗盡 FD。

### 修正方式

- 在 **main context** 設定 `worker_rlimit_nofile`，至少為 `worker_connections` 的 2 倍（經驗值）。
- 同時確認系統總 FD 上限 `fs.file-max` 足夠：
  `worker_rlimit_nofile * worker_processes` 要明顯小於 `fs.file-max`。

```nginx
# main context
worker_connections  1024;         # 在 events {} 內
worker_rlimit_nofile 2048;        # 在 main context
```

### 補充

- NGINX 當 proxy 時：client 連線 1 FD + upstream 連線 1 FD，可能還需要暫存檔 1 FD。
- 若被 DoS 打滿 FD，甚至可能無法登入機器處置，因此要預留系統餘裕。

---

## 2) `error_log off` 其實沒有關閉 error log

### 問題點

- `error_log` **不支援** `off` 參數。
- 寫成 `error_log off;` 會讓 NGINX 產生一個名為 `off` 的檔案（通常在 `/etc/nginx/`）。

### 修正方式（不建議真的關閉）

- 若真的必須停寫 error log（例如磁碟極度有限），改導到 `/dev/null` 並限制等級：

```nginx
# main context
error_log /dev/null emerg;
```

### 補充

- 這條生效前，NGINX 啟動/ reload 驗證設定的過程仍可能先寫到預設路徑（常見 `/var/log/nginx/error.log`）。
- 可用啟動參數 `nginx -e <error_log_location>` 指定啟動階段的 error log 位置。

---

## 3) 沒有對 upstream 啟用 keepalive（導致連線/來源埠耗盡）

### 問題點

- 預設：NGINX 對 upstream **每個 request 都新建連線**，連線建立/關閉都有成本。
- 高流量時會放大 OS 資源消耗；且連線關閉後會進入 `TIME-WAIT`，可能導致 **來源埠（ephemeral ports）耗盡**，進而無法建立新連線。

### 修正方式

**(A) 在每個 `upstream {}` 內加 `keepalive`**

- 參數代表：**每個 worker** 保留在快取中的 _idle keepalive 連線數_（不是總連線上限）。
- 建議值：大約為 upstream server 數量的 2 倍。

```nginx
upstream backend {
    # 若有 load balancing 演算法（hash/ip_hash/least_conn/least_time/random）
    # 要寫在 keepalive 之前（少數需要排序的例外）
    least_conn;

    server 10.0.0.11:8080;
    server 10.0.0.12:8080;

    keepalive 4;  # ~ 2 * servers
}
```

**(B) 在 `location {}` 轉發處，確保上游使用 HTTP/1.1 且移除 `Connection: close`**

```nginx
location / {
    proxy_pass http://backend;

    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

---

## 4) 忘記 directive 的繼承/覆寫規則（尤其是「陣列型」指令）

### 規則重點

- NGINX 指令 **由外到內繼承**（parent → child）。
- 但當 child context 也出現同一 directive 時：**child 會覆寫 parent**，而不是累加。
- 尤其容易踩雷：`add_header`、`proxy_set_header` 這類可以重複出現的「陣列型」指令。

### 範例（重點：location 一旦宣告 `add_header`，就會覆寫上層所有 `add_header`）

```nginx
http {
    add_header X-HTTP-LEVEL-HEADER 1;
    add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;

    server {
        listen 8081;
        add_header X-SERVER-LEVEL-HEADER 1;

        location /test {
            add_header X-LOCATION-LEVEL-HEADER 1;
            return 200 "OK";
        }

        location /correct {
            # 必須把上層想保留的 header 全部在這裡重宣告
            add_header X-HTTP-LEVEL-HEADER 1;
            add_header X-ANOTHER-HTTP-LEVEL-HEADER 1;
            add_header X-SERVER-LEVEL-HEADER 1;
            add_header X-LOCATION-LEVEL-HEADER 1;
            return 200 "OK";
        }
    }
}
```

---

## 5) 濫用 `proxy_buffering off`（效能下降、功能失效）

### 問題點

- 預設：`proxy_buffering on`（開啟代理緩衝）。
- 關閉後：NGINX 只先緩衝很小一段（通常只夠 header），後續會「同步」把 upstream 回應一段段轉給慢速 client，迫使 upstream 等待，整體吞吐下降。
- 副作用：即使你有設定，**快取與限速**等功能也可能無法正常運作（文章強烈不建議改預設）。

### 建議

- 除非是少數情境（例如長輪詢/即時串流等），否則不要關。

```nginx
# 不建議：
proxy_buffering off;

# 建議保留預設：
proxy_buffering on;
```

---

## 6) 在 `location` 裡不當使用 `if`（容易踩坑）

### 問題點

- `if` 在 NGINX 設定中很「危險」，常見行為與直覺不一致，甚至可能造成崩潰（社群常稱 "If is Evil"）。
- 一般安全用法：`if { return ... }` 或 `if { rewrite ... }`。

### 範例：用 `if + error_page` 做分流（相對安全）

```nginx
location / {
    error_page 430 = @error_430;

    if ($http_x_test) {
        return 430;
    }

    proxy_pass http://a;
}

location @error_430 {
    proxy_pass http://b;
}
```

### 更推薦：用 `map` 取代 `if`（更乾淨、可維護）

```nginx
map $http_x_test $upstream_name {
    default "b";
    ""      "a";
}

location / {
    proxy_pass http://$upstream_name;
}
```

---

## 7) 健康檢查（health check）配置過量（對 upstream 造成額外壓力）

### 問題點

- 多個 `server {}` 都 `proxy_pass` 到同一個 `upstream {}` 時，如果每個 `server {}` 都放一次 `health_check`，會造成 **重複探測**、增加 upstream 負載，但資訊並不更完整。

### 修正方式

- 每個 upstream group 只定義 **一套** health check，集中管理（例如放在 named location 或集中到一個監控用的 server）。

```nginx
location / {
    proxy_set_header Host $host;
    proxy_set_header Connection "";
    proxy_http_version 1.1;
    proxy_pass http://b;
}

location @health_check {
    health_check;
    proxy_connect_timeout 2s;
    proxy_read_timeout 3s;
    proxy_set_header Host example.com;
    proxy_pass http://b;
}
```

### 延伸（集中健康檢查 + API/dashboard）

```nginx
server {
    listen 8080;

    location @health_check_b {
        health_check;
        proxy_connect_timeout 2s;
        proxy_read_timeout 3s;
        proxy_set_header Host example.com;
        proxy_pass http://b;
    }

    location /api {
        api write=on;  # NGINX Plus
        # 需限制存取（見 #8）
    }

    location = /dashboard.html {
        root /usr/share/nginx/html;
    }
}
```

---

## 8) 指標（metrics）未加保護（資訊可能被用於攻擊）

### 問題點

- `stub_status`（Open Source）或 `api`（NGINX Plus）暴露的資訊可能敏感。
- 常見錯誤：直接對外公開 URL。

### 修正方式一：HTTP Basic Auth

```nginx
location = /basic_status {
    auth_basic "closed site";
    auth_basic_user_file conf.d/.htpasswd;
    stub_status;
}
```

### 修正方式二：allow/deny 限制來源 IP

```nginx
location = /basic_status {
    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    allow 96.1.2.23/32;
    deny  all;
    stub_status;
}
```

### 組合：`satisfy any`（白名單 IP 免登入，其餘需登入）

```nginx
location = /basic_status {
    satisfy any;

    auth_basic "closed site";
    auth_basic_user_file conf.d/.htpasswd;

    allow 192.168.1.0/24;
    allow 10.1.1.0/16;
    allow 2001:0db8::/32;
    allow 96.1.2.23/32;
    deny  all;

    stub_status;
}
```

---

## 9) `ip_hash` 用錯情境：所有流量看起來都來自同一個 /24

### 問題點

- `ip_hash` 的 key 是 IPv4 的前三個 octets（/24）或整個 IPv6。
- 如果 NGINX 前面有防火牆、L4 LB、gateway 等設備，且它們都在同一個 /24，NGINX 看到的來源 IP（remote addr）就會落在同一 /24，導致 hash key 全相同 → **流量無法分散**。

### 修正方式

- 改用 `hash $binary_remote_addr`，以完整位址（binary）做 key。
- `consistent`（ketama）可降低 server 變動時的重映射比例，提升快取命中率。

```nginx
upstream backend {
    hash $binary_remote_addr consistent;
    server 10.10.20.105:8080;
    server 10.10.20.106:8080;
    server 10.10.20.108:8080;
}
```

---

## 10) 沒有善用 upstream group（即使只有一台後端也值得）

### 常見錯誤

- 直接在 `proxy_pass` 寫死 `host:port`，覺得只有一台不需要 `upstream {}`。
- 但 upstream group 可解鎖更好的連線管理、健康判定、容錯策略等。

### 建議做法（示例）

```nginx
upstream node_backend {
    zone upstreams 64K;                           # shared memory
    server 127.0.0.1:3000 max_fails=1 fail_timeout=2s;
    keepalive 2;
}

server {
    listen 80;
    server_name example.com;

    location / {
        proxy_set_header Host $host;
        proxy_pass http://node_backend/;

        proxy_next_upstream error timeout http_500;
    }
}
```

### 補充

- `zone`：讓多個 worker 共享 upstream 狀態；NGINX Plus 也可搭配 API 動態調整 upstream（不需重啟）。
- `server ... max_fails/fail_timeout`：更精準控制「不健康」判定。
- `proxy_next_upstream`：定義哪些錯誤要切到下一台（例：`http_500` 也視為失敗）。

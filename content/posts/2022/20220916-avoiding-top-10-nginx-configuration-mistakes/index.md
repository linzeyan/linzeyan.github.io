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

## 1) Not enough file descriptors (FDs) per worker

### What's wrong

- `worker_connections` limits how many concurrent connections **a single worker** can hold (default 512).
- But each worker is also limited by the OS per-process **file descriptor** limit (often 1024 by default).
- Common mistake: increasing `worker_connections` but not raising the FD limit, causing early exhaustion.

### Fix

- Set `worker_rlimit_nofile` in the **main context** to at least **2×** `worker_connections` (rule of thumb).
- Also validate the system-wide FD cap (`fs.file-max`) so that:
  `worker_rlimit_nofile * worker_processes` is well below `fs.file-max`.

```nginx
# main context
worker_connections  1024;      # inside events {}
worker_rlimit_nofile 2048;     # main context
```

---

## 2) The `error_log off` directive (it does not disable error logging)

### What's wrong

- Unlike `access_log`, `error_log` does **not** accept an `off` parameter.
- `error_log off;` creates a file literally named `off` (often under `/etc/nginx/`).

### Fix (generally not recommended)

- If you must suppress error logging due to storage constraints, send it to `/dev/null` and restrict severity:

```nginx
# main context
error_log /dev/null emerg;
```

### Note

- This only applies after NGINX reads and validates config; startup/reload may still log to the default location unless you start NGINX with `-e <error_log_location>`.

---

## 3) Not enabling keepalive connections to upstream servers

### What's wrong

- Default behavior: NGINX opens a new upstream connection for each request.
- At high load this can consume resources and can exhaust ephemeral source ports due to TIME-WAIT, preventing new upstream connections.

### Fix

**(A) Add `keepalive` to each `upstream {}`**

- The value is the number of **idle** keepalive connections cached **per worker** (not a global cap).
- Practical guidance: about **2×** the number of servers in the upstream group.

```nginx
upstream backend {
    # If you use a load-balancing method (hash/ip_hash/least_conn/least_time/random),
    # it must appear above keepalive (rare ordering exception).
    least_conn;

    server 10.0.0.11:8080;
    server 10.0.0.12:8080;

    keepalive 4;  # ~ 2 * servers
}
```

**(B) Ensure upstream uses HTTP/1.1 and remove `Connection: close`**

```nginx
location / {
    proxy_pass http://backend;

    proxy_http_version 1.1;
    proxy_set_header Connection "";
}
```

---

## 4) Forgetting directive inheritance and override behavior (especially "array" directives)

### Key rule

- Directives inherit "outside-in" (parent → child).
- If the same directive appears in a child context, it **overrides** the parent, it does not "add to" it.
- Easy to get wrong: `add_header`, `proxy_set_header`, etc.

### Example (a location-level `add_header` overrides all inherited `add_header`s)

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
            # Re-declare everything you want to keep
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

## 5) The `proxy_buffering off` directive (often harmful)

### What's wrong

- Default is `proxy_buffering on`. NGINX buffers upstream responses and then serves slow clients efficiently.
- With buffering off, NGINX starts streaming after a tiny initial buffer, forcing upstream servers to wait for slow clients; throughput drops.
- Side effects include degraded performance and certain features (like caching/rate limiting) not working as intended.

### Recommendation

- Avoid turning buffering off except for narrow use cases (e.g., some long-polling scenarios).

```nginx
# Not recommended in general:
proxy_buffering off;

# Keep default:
proxy_buffering on;
```

---

## 6) Improper use of the `if` directive (especially inside `location {}`)

### What's wrong

- `if` is notoriously tricky in NGINX; behavior is often surprising and can be unsafe in complex cases.
- The reliably safe directives inside `if` are typically `return` and `rewrite`.

### Safer pattern: `if + error_page` for steering

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

### Prefer `map` to avoid `if`

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

## 7) Excessive health checks

### What's wrong

- If multiple virtual servers proxy to the same upstream group, placing `health_check` in each server block duplicates probes, increases upstream load, and provides no extra value.

### Fix

- Define **one** health check per upstream group (e.g., a named location), and centralize management.

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

### Optional: central "monitoring" server (health checks + API/dashboard)

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
        # Restrict access (see #8)
    }

    location = /dashboard.html {
        root /usr/share/nginx/html;
    }
}
```

---

## 8) Unsecured access to metrics endpoints

### What's wrong

- `stub_status` (Open Source) and the NGINX Plus `api` can expose operational details that may aid attackers.
- Common mistake: exposing the endpoint publicly.

### Fix option A: HTTP Basic Auth

```nginx
location = /basic_status {
    auth_basic "closed site";
    auth_basic_user_file conf.d/.htpasswd;
    stub_status;
}
```

### Fix option B: `allow` / `deny` IP restrictions

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

### Combine both: `satisfy any`

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

## 9) Using `ip_hash` when all traffic appears from the same /24 CIDR block

### What's wrong

- `ip_hash` uses the first three octets of IPv4 (effectively /24) as the hash key, or the full IPv6 address.
- If upstream traffic is "fronted" by devices all in the same /24, NGINX sees the same first three octets for all clients → same hash key → no distribution.

### Fix

- Use `hash $binary_remote_addr` for a full-address key.
- Use `consistent` (ketama) to reduce remapping when the server set changes.

```nginx
upstream backend {
    hash $binary_remote_addr consistent;
    server 10.10.20.105:8080;
    server 10.10.20.106:8080;
    server 10.10.20.108:8080;
}
```

---

## 10) Not taking advantage of upstream groups (even with a single backend)

### What's wrong

- Writing `proxy_pass http://host:port` directly is common for a single backend.
- But defining an `upstream {}` unlocks better connection reuse, health tuning, failover behavior, and observability.

### Improved pattern (example)

```nginx
upstream node_backend {
    zone upstreams 64K;                           # shared memory zone
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

### Notes

- `zone`: shares upstream state across workers; in NGINX Plus it also enables API-driven changes without restart.
- `max_fails`/`fail_timeout`: tighter unhealthy detection behavior (example shown).
- `proxy_next_upstream`: declares which conditions trigger trying the "next" server (here includes `http_500`).

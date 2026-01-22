---
title: "Record Millisecond Precision in Nginx Access Logs"
date: 2018-07-24T18:31:42+08:00
menu:
  sidebar:
    name: "Record Millisecond Precision in Nginx Access Logs"
    identifier: nginx-access-log-milliseconds-server-time
    weight: 10
tags: ["Nginx", "Lua"]
categories: ["Nginx", "Lua"]
hero: images/hero/nginx.jpeg
---

Nginx access logs can record millisecond timestamps, but they are milliseconds since `EPOCH`, for example `1503544071.865`. Another variable, `$time_local`, records a second-level time format, for example `24/Aug/2017:11:07:51 +0800`. Under heavy traffic, we need a millisecond-precision format like `24/Aug/2017:11:07:51.865 +0800`. This can be done with Lua.

First, define a variable named `time_millis` in nginx.conf and initialize it to empty. This is similar to providing a fallback self-signed certificate when using `auto-ssl`.

```nginx
    map $host $time_millis {
        default '';
    }
```

If this variable is not defined, referencing it in `log_format` will cause errors.

Use Lua to get milliseconds and append them to the end of `$time_local`.

```nginx
    log_by_lua_block {
        millis = string.gsub(ngx.var.msec, "(%d+).(%d+)", "%2")
        ngx.var.time_millis = string.gsub(ngx.var.time_local, "(.+) (.+)", "%1." .. millis .. " %2")
    }
```

Replace `$time_local` with `$time_millis` in `log_format`.

```nginx
http {
    map $host $time_millis {
        default '';
    }

    log_by_lua_block {
        millis = string.gsub(ngx.var.msec, "(%d+).(%d+)", "%2")
        ngx.var.time_millis = string.gsub(ngx.var.time_local, "(.+) (.+)", "%1." .. millis .. " %2")
    }

    log_format  main  '$remote_addr - $remote_user [$time_millis] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" $msec "$http_x_forwarded_for" $host $request_time $upstream_response_time $scheme "$request_body"';
}
```

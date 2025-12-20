---
title: "Nginx 访问日志中记录毫秒级别的时间精度"
date: 2018-07-24T18:31:42+08:00
menu:
  sidebar:
    name: "Nginx 访问日志中记录毫秒级别的时间精度"
    identifier: nginx-access-log-milliseconds-server-time
    weight: 10
tags: ["Nginx", "Lua"]
categories: ["Nginx", "Lua"]
hero: images/hero/nginx.jpeg
---

Nginx 的 access log 可以记录毫秒级的时间戳，但是是以 `EPOCH` 开始的毫秒数，比如 `1503544071.865`, 另一个变量 `$time_local` 记录的是秒级别的时间格式，比如 `24/Aug/2017:11:07:51 +0800`，在业务量大的时候，我们需要记录毫秒精度的时间格式，比如 `24/Aug/2017:11:07:51.865 +0800`, 这个可以通过 Lua 实现。

首先需要在 nginx.conf 中定义一个变量，叫做 `time_millis`，并初始化为空。类似于使用 `auto-ssl` 获取证书的时候需要指定一个 fallback 的自签证书。

```nginx
    map $host $time_millis {
        default '';
    }
```

如果不定义这个变量，在 `log_format` 中引用的时候会报错。

使用 Lua 获取毫秒数，并追加到 `$time_local` 的末尾。

```nginx
    log_by_lua_block {
        millis = string.gsub(ngx.var.msec, "(%d+).(%d+)", "%2")
        ngx.var.time_millis = string.gsub(ngx.var.time_local, "(.+) (.+)", "%1." .. millis .. " %2")
    }
```

在 `log_format` 中将 `$time_local` 改为 `$time_millis`

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

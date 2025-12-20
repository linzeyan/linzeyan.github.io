---
title: "降低家用 Web 服务被通报的概率"
date: 2025-10-02T09:54:00+08:00
menu:
  sidebar:
    name: "降低家用 Web 服务被通报的概率"
    identifier: nginx-hide-web
    weight: 10
tags: ["URL", "NGINX"]
categories: ["URL", "NGINX"]
hero: images/hero/nginx.jpeg
---

- [降低家用 Web 服务被通报的概率](https://tao.zz.ac/homelab/hide-web.html)

- 通过明文协议尝试请求 HTTPS 服务在 Nginx 中有分配特殊的 497 状态码。如果发生该报错，我们希望 Nginx 直接关闭连接，不返回任何响应。这需要用到另外一个非标状态码 444，综合两种状态码，我们需要在 server 中增加如下配置：

```nginx
error_page 497 @close;

location @close {
    return 444;
}
```

使用 error_page 指令为 497 状态码设置虚拟路径@close，Nginx 在处理的@close 时发现是返回 444 状态码，于是直接关闭连接。

这个时候你再用 curl 访问对应的端口就会收到如下报错：

curl http://example.zz.ac:5678
curl: (52) Empty reply from server

```nginx
server {
        listen 5678 ssl;
        listen [::]:5678 ssl;

        server_name example.zz.ac;

        ssl_certificate ...;
        ssl_certificate_key ..;

        error_page 497 @close;

        location @close {
                return 444;
        }
        ...
}
server {
        listen 5678 ssl default_server;;
        listen [::]:5678 ssl default_server;;

        server_name _;

        ssl_certificate ...;
        ssl_certificate_key ..;

        return 444;
}
```

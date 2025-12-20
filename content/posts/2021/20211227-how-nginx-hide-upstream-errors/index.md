---
title: "Nginx怎样隐藏上游错误"
date: 2021-12-27T15:47:12+08:00
menu:
  sidebar:
    name: "Nginx怎样隐藏上游错误"
    identifier: nginx-hide-upstream-errors
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx 怎样隐藏上游错误](https://russelltao.github.io/2021/02/22/nginx/Nginx%E6%80%8E%E6%A0%B7%E9%9A%90%E8%97%8F%E4%B8%8A%E6%B8%B8%E9%94%99%E8%AF%AF/#more)

##### Nginx 允许对以下 7 种可以进行重试的错误码启用 next upstream 功能

- 403 Forbidden
- 404 Not Found
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Server Unavailable
- 504 Gateway Timeout

##### 当上游返回 404 错误时，改为通过 200 返回一张找不到资源的图片

> 此时，可以通过 `proxy_intercept_errors` 指令完成这一功能
> 当 `proxy_intercept_errors` 开启后，对于上游返回的大于等于 300 响应码的请求，都可以基于 error_page 指令继续处理

```nginx
location /ih {
        proxy_pass http://ihBackend;
        proxy_intercept_errors on;
        error_page 404 = /404.html;
}
location = /404.html {
        alias html/404_not_found.html;
}
```

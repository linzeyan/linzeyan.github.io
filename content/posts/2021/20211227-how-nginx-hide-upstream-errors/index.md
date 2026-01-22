---
title: "How Nginx Hides Upstream Errors"
date: 2021-12-27T15:47:12+08:00
menu:
  sidebar:
    name: "How Nginx Hides Upstream Errors"
    identifier: nginx-hide-upstream-errors
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [How Nginx Hides Upstream Errors](https://russelltao.github.io/2021/02/22/nginx/Nginx%E6%80%8E%E6%A0%B7%E9%9A%90%E8%97%8F%E4%B8%8A%E6%B8%B8%E9%94%99%E8%AF%AF/#more)

##### Nginx allows enabling next upstream for the following seven retryable error codes

- 403 Forbidden
- 404 Not Found
- 429 Too Many Requests
- 500 Internal Server Error
- 502 Bad Gateway
- 503 Server Unavailable
- 504 Gateway Timeout

##### When upstream returns 404, return a 200 response with a not-found image

> You can use `proxy_intercept_errors` to achieve this.\n> When `proxy_intercept_errors` is enabled, requests with upstream response codes >= 300 can be further handled via the error_page directive.

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

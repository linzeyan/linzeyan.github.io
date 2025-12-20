---
title: "Top 25 Nginx Tips and Tricks From Practical Experience"
date: 2022-08-10T12:27:28+08:00
menu:
  sidebar:
    name: "Top 25 Nginx Tips and Tricks From Practical Experience"
    identifier: nginx-top-25-nginx-tips-and-tricks-from-practical-experience
    weight: 10
tags: ["URL", "NGINX"]
categories: ["URL", "NGINX"]
hero: images/hero/nginx.jpeg
---

- [Top 25 Nginx Tips and Tricks From Practical Experience](https://hackernoon.com/top-25-nginx-tips-and-tricks-from-practical-experience)

- `server_tokens off;`
- `ssl_protocols TLSv1.2 TLSv1.3;`
- Disable any undesirable HTTP methods

```nginx
  location / {
    limit_except GET HEAD POST { deny all; }
  }
```

- Enable sysctl based protection

```shell
net.ipv4.conf.all.rp_filter = 1
net.ipv4.tcp_syncookies = 1
```

- Stop image hotlinking

```nginx
location /images/ {
  valid_referers none blocked www.domain.com domain.com;
   if ($invalid_referer) {
     return   403;
   }
}
```

- `add_header X-Content-Type-Options nosniff;`
- `add_header X-XSS-Protection "1; mode=block";`
- `add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;`
-

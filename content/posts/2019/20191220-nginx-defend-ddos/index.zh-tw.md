---
title: "Nginx 如何防禦 DDoS 攻擊？"
date: 2019-12-20T09:42:50+08:00
menu:
  sidebar:
    name: "Nginx 如何防禦 DDoS 攻擊？"
    identifier: nginx-how-to-defend-ddos
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Nginx 如何防禦 DDoS 攻擊？](https://magiclen.org/nginx-defend-ddos/)
- [Nginx 限制訪問速率和最大併發連線數模組--limit（防止 DDoS 攻擊）](https://www.itread01.com/content/1547474225.html)

#### ngx_http_limit_req_module

`limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;`

---
title: "How Does Nginx Defend Against DDoS?"
date: 2019-12-20T09:42:50+08:00
menu:
  sidebar:
    name: "How Does Nginx Defend Against DDoS?"
    identifier: nginx-how-to-defend-ddos
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [How Does Nginx Defend Against DDoS?](https://magiclen.org/nginx-defend-ddos/)
- [Nginx limit module for access rate and max concurrent connections (DDoS protection)](https://www.itread01.com/content/1547474225.html)

#### ngx_http_limit_req_module

`limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;`

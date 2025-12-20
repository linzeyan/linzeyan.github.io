---
title: "Nginx SSL/TLS configuration with TLSv1.2 and TLSv1.3 - ECDHE and strong ciphers suite (Openssl 1.1.1)"
date: 2021-01-22T13:49:17+08:00
menu:
  sidebar:
    name: "Nginx SSL/TLS configuration with TLSv1.2 and TLSv1.3 - ECDHE and strong ciphers suite (Openssl 1.1.1)"
    identifier: nginx-tls-configuration-ecdhe-7d432c3c3d134cc3cb7e98b30a76c287
    weight: 10
tags: ["URL", "Nginx", "TLS"]
categories: ["URL", "Nginx", "TLS"]
hero: images/hero/nginx.jpeg
---

- [Nginx SSL/TLS configuration with TLSv1.2 and TLSv1.3 - ECDHE and strong ciphers suite (Openssl 1.1.1)](https://gist.github.com/VirtuBox/7d432c3c3d134cc3cb7e98b30a76c287)

##### ssl.conf

```nginx
##
# SSL Settings (TLSv1.2 and TLSv1.3)
##
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'TLS13+AESGCM+AES128:EECDH+AES128';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;
ssl_ecdh_curve X25519:sect571r1:secp521r1:secp384r1
```

##### universal-ssl.conf

```nginx
##
# SSL Settings (TLSv1.0 + TLSv1.1 + TLSv1.2 + TLSv1.3)
##
ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
ssl_ciphers 'TLS13+AESG+AES128:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES25GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:DHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-R-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-S:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
ssl_prefer_server_ciphers on;
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;
ssl_ecdh_curve X25519:sect571r1:secp521r1:secp384r1;
```

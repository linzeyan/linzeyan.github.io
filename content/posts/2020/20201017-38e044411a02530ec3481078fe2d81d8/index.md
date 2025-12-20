---
title: "Nginx HTTPS with Basic Auth reverse proxy for VMware ESXi 6.5 fixed VMRC /screen"
date: 2020-10-17T12:31:02+08:00
menu:
  sidebar:
    name: "Nginx HTTPS with Basic Auth reverse proxy for VMware ESXi 6.5 fixed VMRC /screen"
    identifier: nginx-reverse-proxy-with-basic-auth-for-esxi
    weight: 10
tags: ["URL", "Nginx", "ESXi"]
categories: ["URL", "Nginx", "ESXi"]
hero: images/hero/nginx.jpeg
---

- [Nginx HTTPS with Basic Auth reverse proxy for VMware ESXi 6.5 fixed VMRC /screen](https://gist.github.com/dbrownidau/38e044411a02530ec3481078fe2d81d8)

```nginx
server {
    listen 80;
    server_name esxi.hackion.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl;
    server_name esxi.hackion.com;

    ssl_certificate /mycert.crt;
    ssl_certificate_key /mykey.key;

    location / {
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Origin '';
        proxy_set_header Authorization ''; #Don't pass the Nginx Basic Auth to ESXi or it will break VMRC.
        proxy_pass_header X-XSRF-TOKEN;
        proxy_pass https://esxi_server;
        proxy_send_timeout      300;
        proxy_read_timeout      300;
        send_timeout            300;
        client_max_body_size    1000m;

        # enables WS support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

```

---

```nginx
server {
    listen 443 ssl http2;

    # ssl_certificate and ssl_certificate_key are required
    ssl_certificate     /etc/letsencrypt/live/myletsencryptdomain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/myletsencryptdomain/privkey.pem;

    include /etc/nginx/snippets/ssl-params.conf;
    # removed DH params as my ssl-params.conf specifies to only use ECDHE key exchange.

    server_name fqdn.extern;

    location / {
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_ssl_verify off; # No need on isolated LAN
        proxy_pass https://vcenter.ip; # esxi IP Address

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_buffering off;
        client_max_body_size 0;
        proxy_read_timeout 36000s;

        proxy_redirect https://fqdn.local/ https://fqdn.extern/; # read comment below
        # replace vcenter-hostname with your actual vcenter's hostname, and esxi with your nginx's server_name.
    }

    location /websso/SAML2 {
        proxy_set_header Host fqdn.local; # your actual vcenter's hostname
        proxy_set_header X-Real-IP $remote_addr;

        proxy_ssl_verify off; # No need on isolated LAN
        proxy_pass https://vcenter.ip; # esxi IP Address

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_buffering off;
        client_max_body_size 0;
        proxy_read_timeout 36000s;
        proxy_ssl_session_reuse on;

        proxy_redirect https://fqdn.local/ https://fqdn.extern/; # read comment below
        # replace vcenter-hostname with your actual vcenter's hostname, and esxi with your nginx's server_name.
    }
}
```

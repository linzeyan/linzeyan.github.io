---
title: "Force file download with Nginx"
date: 2019-08-19T12:12:32+08:00
menu:
  sidebar:
    name: "Force file download with Nginx"
    identifier: nginx-force-file-download-with-nginx
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Force file download with Nginx](https://coderwall.com/p/3yb8vg/force-file-download-with-nginx)

`add_header Content-Disposition 'attachment;';`

```nginx
server {
    listen 80;
    server_name my.domain.com;
    location ~ ^.*/(?P<request_basename>[^/]+\.(mp3))$ {
        root /path/to/mp3/
        add_header Content-Disposition 'attachment; filename="$request_basename"';
    }
}
```

```nginx
{
    listen 80;
    server_name  backup.baifu-tech.net;
    root /data/backup/rechargecent-mago;
    location / {
        auth_basic   "baifu backup center";
        auth_basic_user_file /etc/nginx/ssl/htpasswd;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
    }
}
```

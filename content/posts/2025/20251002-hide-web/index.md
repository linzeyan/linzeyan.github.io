---
title: "Reduce the Chance of Home Web Services Being Reported"
date: 2025-10-02T09:54:00+08:00
menu:
  sidebar:
    name: "Reduce the Chance of Home Web Services Being Reported"
    identifier: nginx-hide-web
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Reduce the Chance of Home Web Services Being Reported](https://tao.zz.ac/homelab/hide-web.html)

- When a plaintext request hits an HTTPS service, Nginx returns a special 497 status code. If that happens, we want Nginx to close the connection and return no response. This requires another non-standard status code 444. Combining the two, add the following config in the server:

```nginx
error_page 497 @close;

location @close {
    return 444;
}
```

Use the error_page directive to map 497 to the virtual path @close. When Nginx handles @close, it returns 444 and closes the connection.

If you curl the port, you will see:

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

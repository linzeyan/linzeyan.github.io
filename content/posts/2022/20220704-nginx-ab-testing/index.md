---
title: "Simple A/B Testing with Nginx split_clients"
date: 2022-07-04T14:36:23+08:00
menu:
  sidebar:
    name: "Simple A/B Testing with Nginx split_clients"
    identifier: nginx-ab-testing-split-clients
    weight: 10
tags: ["Links", "Nginx", "Testing"]
categories: ["Links", "Nginx", "Testing"]
hero: images/hero/nginx.jpeg
---

- [Simple A/B Testing with Nginx split_clients](https://u.sb/nginx-ab-testing/)

##### [ngx_http_split_clients_module](https://nginx.org/en/docs/http/ngx_http_split_clients_module.html)

##### Configure

> For example, suppose we want 20% of users to be redirected to https://example.com/, 30% to https://example.org/, and the rest to https://example.edu/.

```nginx
split_clients "${remote_addr}AAA" $variant {
    20%               https://example.com/;
    30%               https://example.org/;
    *                 https://example.edu/;
}

server {
    listen 80;
    listen [::]:80;
    server_name _;

    return 302 ${variant};
}
```

In the example above, the visitor's IP address plus the string AAA is hashed with MurmurHash2 into a number. If the number falls in the first 20%, $variant is https://example.com/. If it falls in the middle 30%, $variant is https://example.org/. Otherwise it is https://example.edu/.

###### Specify different directories

```nginx
root /var/www/${variant};
```

###### Specify different index pages

```nginx
index index-${variant}.html;
```

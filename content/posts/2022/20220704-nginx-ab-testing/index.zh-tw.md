---
title: "Nginx 使用 split_clients 进行简易 A/B 测试"
date: 2022-07-04T14:36:23+08:00
menu:
  sidebar:
    name: "Nginx 使用 split_clients 进行简易 A/B 测试"
    identifier: nginx-ab-testing-split-clients
    weight: 10
tags: ["URL", "NGINX", "Testing"]
categories: ["URL", "NGINX", "Testing"]
hero: images/hero/nginx.jpeg
---

- [Nginx 使用 split_clients 进行简易 A/B 测试](https://u.sb/nginx-ab-testing/)

##### [ngx_http_split_clients_module](https://nginx.org/en/docs/http/ngx_http_split_clients_module.html)

##### configure

> 这里举例，我们想要 20% 的用户跳转到网址 https://example.com/，30% 的用户跳转到网址 https://example.org/，剩下的跳转到网址 https://examle.edu/

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

上述例子中，按照访客请求的 IP 地址 加上 AAA 字符串 会使用 MurmurHash2 转换成数字，如果得出的数字在前 20%，那么 $variant 值为 https://example.com/，相应的在中间 30% 区间的值为 https://example.org/，其他的为 https://example.edu/。

###### 指定不同的目录

```nginx
root /var/www/${variant};
```

###### 指定不同的首页

```nginx
index index-${variant}.html;
```

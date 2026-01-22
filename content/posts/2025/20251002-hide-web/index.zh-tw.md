---
title: "降低家用 Web 服務被通報的機率"
date: 2025-10-02T09:54:00+08:00
menu:
  sidebar:
    name: "降低家用 Web 服務被通報的機率"
    identifier: nginx-hide-web
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [降低家用 Web 服務被通報的機率](https://tao.zz.ac/homelab/hide-web.html)

- 透過明文協議嘗試請求 HTTPS 服務時，Nginx 會回傳特殊的 497 狀態碼。若發生此錯誤，我們希望 Nginx 直接關閉連線，不回傳任何回應。這需要另一個非標準狀態碼 444。綜合兩種狀態碼，我們需要在 server 中加入如下設定：

```nginx
error_page 497 @close;

location @close {
    return 444;
}
```

使用 error_page 指令為 497 狀態碼設定虛擬路徑 @close，Nginx 在處理 @close 時發現要回傳 444，於是直接關閉連線。

此時你再用 curl 造訪對應埠口會看到如下錯誤：

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

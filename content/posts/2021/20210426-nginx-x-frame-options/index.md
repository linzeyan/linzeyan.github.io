---
title: "Bypass X-Frame-Options with Nginx"
date: 2021-04-26T17:39:33+08:00
menu:
  sidebar:
    name: "Bypass X-Frame-Options with Nginx"
    identifier: nginx-x-frame-options
    weight: 10
tags: ["Links", "Nginx"]
categories: ["Links", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [Bypass X-Frame-Options with Nginx](https://blog.whezh.com/nginx-x-frame-options/)

The `X-Frame-Options` HTTP response header tells the browser whether a page can be displayed inside `<frame>`, `<iframe>`, `<embed>`, or `<object>`. Sites can prevent clickjacking by ensuring their pages are not embedded elsewhere. By using Nginx as a forward proxy, we can bypass `X-Frame-Options` and embed a third-party page in our own page.

`X-Frame-Options` has three possible values:

- deny: the page cannot be displayed in a frame, even on the same origin.
- sameorigin: the page can be displayed in a frame on the same origin.
- allow-from uri: the page can be displayed in a frame only from the specified origin.

When Chrome tries to load frame content and `X-Frame-Options` denies it, the console shows an error like:
`Refuse to display 'http://192.168.20.101:8080' in a frame because it set 'X-Frame-Options' to 'deny'.`

```nginx
server {
  listen       8080;
  location / {
    proxy_hide_header X-Frame-Options;
    proxy_pass http://{target};
  }
}
```

When you request `http://{proxy_server}:8080`, nginx proxies to `http://{target}` and hides the `X-Frame-Options` header in the response. This allows your page to load the target page in an iframe.

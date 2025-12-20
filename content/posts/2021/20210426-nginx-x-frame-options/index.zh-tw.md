---
title: "通过 Nginx 绕过 X-Frame-Options 限制"
date: 2021-04-26T17:39:33+08:00
menu:
  sidebar:
    name: "通过 Nginx 绕过 X-Frame-Options 限制"
    identifier: nginx-x-frame-options
    weight: 10
tags: ["URL", "Nginx"]
categories: ["URL", "Nginx"]
hero: images/hero/nginx.jpeg
---

- [通过 Nginx 绕过 X-Frame-Options 限制](https://blog.whezh.com/nginx-x-frame-options/)

`X-Frame-Options` HTTP 响应头是用来给浏览器指示允许一个页面是否可以在 `<frame>`,` <iframe>`, `<embed>` 或者 `<object>` 中展现的标记。站点可以通过确保网站没有被嵌入到别人的站点里面，从而避免 Clickjacking 攻击。通过 Nginx 的作为正向代理，我们可以绕过 `X-Frame-Options` 限制成功的将第三方网页嵌入到自己的页面中。

X-Frame-Options 响应头有三个可能的值：

- deny: 表示该页面不允许在 frame 中展示，即便是在相同域名的页面中嵌套也不允许。
- sameorigin: 表示该页面可以在相同域名页面的 frame 中展示。
- allow-from uri: 表示该页面可以在指定来源的 frame 中展示。

在 Chrome 尝试加载 frame 的内容时，如果 X-Frame-Options 响应头设置为禁止访问，那么 Chrome 会在控制台中显示如下错误。
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

这也当请求 `http://{proxy_server}:8080` 时，nginx 会做代理转发到 `http://{target}`，同时在返回结果的时候会隐藏掉 `X-Frame-Options` 相应头，这样我们自己的网页就能正常通过 iFrame 载入目标网页了。

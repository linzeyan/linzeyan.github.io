---
title: "把 Cloudflare WARP 转换为 http 代理"
date: 2024-11-06T17:47:06+08:00
menu:
  sidebar:
    name: "把 Cloudflare WARP 转换为 http 代理"
    identifier: cloudflare-warp-http-proxy
    weight: 10
tags: ["URL", "Cloudflare"]
categories: ["URL", "Cloudflare"]
hero: images/hero/cloudflare.svg
---

- [把 Cloudflare WARP 转换为 http 代理](https://dmesg.app/warp-http-proxy.html)

```shell
warp-cli proxy port 60606
warp-cli mode proxy
```

然而，Go 的程序不支持 socks 代理，要手动加 transport 我可没那个功夫去加。

好消息是，Go 默认是尊重环境变量 http_proxy 的。那么就要想办法给 socks 代理转换为 http 代理

```shell
pproxy -v -l http://127.0.0.1:8118 -r socks5://127.0.0.1:60606

https_proxy=http://127.0.0.1:8118 http_proxy=http://127.0.0.1:8118 curl ipv4.win
curl: (52) Empty reply from server

# pproxy logs
Serving on ipv? 127.0.0.1:8118 by http
http 127.0.0.1:45012 -> socks5 127.0.0.1:60606 -> ipv4.win:80
Unknown remote protocol from 127.0.0.1
```

可能是 pproxy 的问题，那么用 gost

```shell
gost -L http://127.0.0.1:8118 -F socks5://127.0.0.1:60606
2024/11/03 12:32:43 route.go:700: http://127.0.0.1:8118 on 127.0.0.1:8118
2024/11/03 12:32:46 http.go:162: [http] 127.0.0.1:33284 -> http://127.0.0.1:8118 -> ipv4.win:80
2024/11/03 12:32:46 http.go:257: [route] 127.0.0.1:33284 -> http://127.0.0.1:8118 -> 1@socks5://127.0.0.1:60606 -> ipv4.win:80
2024/11/03 12:32:46 http.go:280: [http] 127.0.0.1:33284 -> 127.0.0.1:8118 : unexpected EOF
```

那……Privoxy

```shell
forward-socks5 / 127.0.0.1:60606 .
```

偶然取消 DNS 请求的勾选，就成功了…… 突然恍然大悟，WARP 可能不支持远程解析 DNS

- 要么用回 socks4
  ```shell
  pproxy -v -l http://127.0.0.1:8118 -r socks4://127.0.0.1:60606
  gost -L http://127.0.0.1:8118 -F socks4://127.0.0.1:60606
  ```
- 要么给加上 DNS 的支持: `gost -L "http://127.0.0.1:8118?dns=1.1.1.1" -F socks5://127.0.0.1:60606`

需要注意：warp-cli 的 proxy mode 不支持超过 10 秒的连接

遇到这种情况，要么不用 proxy mode， 要么在 gost 或 pproxy 那边绕过

`gost -L http://127.0.0.1:8118 -F socks4://127.0.0.1:60606?bypass=api.openai.com`

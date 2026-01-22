---
title: "Convert Cloudflare WARP to an HTTP Proxy"
date: 2024-11-06T17:47:06+08:00
menu:
  sidebar:
    name: "Convert Cloudflare WARP to an HTTP Proxy"
    identifier: cloudflare-warp-http-proxy
    weight: 10
tags: ["Links", "Cloudflare"]
categories: ["Links", "Cloudflare"]
hero: images/hero/cloudflare.svg
---

- [Convert Cloudflare WARP to an HTTP Proxy](https://dmesg.app/warp-http-proxy.html)

```shell
warp-cli proxy port 60606
warp-cli mode proxy
```

However, Go programs do not support SOCKS proxies, and I don't want to manually add a transport.

The good news is that Go respects the `http_proxy` environment variable by default. So we need to convert the SOCKS proxy to an HTTP proxy.

```shell
pproxy -v -l http://127.0.0.1:8118 -r socks5://127.0.0.1:60606

https_proxy=http://127.0.0.1:8118 http_proxy=http://127.0.0.1:8118 curl ipv4.win
curl: (52) Empty reply from server

# pproxy logs
Serving on ipv? 127.0.0.1:8118 by http
http 127.0.0.1:45012 -> socks5 127.0.0.1:60606 -> ipv4.win:80
Unknown remote protocol from 127.0.0.1
```

Maybe it's a pproxy issue, so try gost.

```shell
gost -L http://127.0.0.1:8118 -F socks5://127.0.0.1:60606
2024/11/03 12:32:43 route.go:700: http://127.0.0.1:8118 on 127.0.0.1:8118
2024/11/03 12:32:46 http.go:162: [http] 127.0.0.1:33284 -> http://127.0.0.1:8118 -> ipv4.win:80
2024/11/03 12:32:46 http.go:257: [route] 127.0.0.1:33284 -> http://127.0.0.1:8118 -> 1@socks5://127.0.0.1:60606 -> ipv4.win:80
2024/11/03 12:32:46 http.go:280: [http] 127.0.0.1:33284 -> 127.0.0.1:8118 : unexpected EOF
```

Then... Privoxy.

```shell
forward-socks5 / 127.0.0.1:60606 .
```

After unchecking DNS requests, it worked... Then it hit me: WARP may not support remote DNS resolution.

- Either switch to socks4
  ```shell
  pproxy -v -l http://127.0.0.1:8118 -r socks4://127.0.0.1:60606
  gost -L http://127.0.0.1:8118 -F socks4://127.0.0.1:60606
  ```
- Or add DNS support: `gost -L "http://127.0.0.1:8118?dns=1.1.1.1" -F socks5://127.0.0.1:60606`

Note: warp-cli proxy mode does not support connections longer than 10 seconds.

If that happens, either stop using proxy mode or bypass it in gost or pproxy.

`gost -L http://127.0.0.1:8118 -F socks4://127.0.0.1:60606?bypass=api.openai.com`

---
title: "隐藏于 Cloudflare 的全球网络之中"
date: 2024-08-01T14:35:24+08:00
menu:
  sidebar:
    name: "隐藏于 Cloudflare 的全球网络之中"
    identifier: cloudflare-hide-ip-in-cf
    weight: 10
tags: ["URL", "Cloudflare"]
categories: ["URL", "Cloudflare"]
hero: images/hero/cloudflare.svg
---

- [隐藏于 Cloudflare 的全球网络之中](https://dmesg.app/hide-in-cf.html)

1. 一种方式是走 Cloudflare WARP，WARP 可以运行在 proxy mode 而不是接管全局流量

```shell
warp-cli register
# warp 监听本地的11111端口
warp-cli set-proxy-port 11111

# warp proxy mode
warp-cli set-mode proxy

# 永久开启
warp-cli enable-always-on
```

```shell
https_proxy=socks5://127.0.0.1:11111 http_proxy=socks5://127.0.0.1:11111 go run main.go
```

2. 还有一种方式是使用 Cloudflare Workers，请求由 Workers 转发

```javascript
export default {
	async fetch(request: Request): Promise {
		/**
		 * Replace `remote` with the host you wish to send requests to
		 */
		const remote = "https://example.com";

		return await fetch(remote, request);
	},
};
```

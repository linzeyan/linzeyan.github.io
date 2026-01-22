---
title: "隱藏於 Cloudflare 的全球網路之中"
date: 2024-08-01T14:35:24+08:00
menu:
  sidebar:
    name: "隱藏於 Cloudflare 的全球網路之中"
    identifier: cloudflare-hide-ip-in-cf
    weight: 10
tags: ["Links", "Cloudflare"]
categories: ["Links", "Cloudflare"]
hero: images/hero/cloudflare.svg
---

- [隱藏於 Cloudflare 的全球網路之中](https://dmesg.app/hide-in-cf.html)

1. 一種方式是使用 Cloudflare WARP，讓 WARP 以 proxy mode 執行，而不是接管全域流量。

```shell
warp-cli register
# WARP 監聽本機的 11111 埠
warp-cli set-proxy-port 11111

# WARP proxy mode
warp-cli set-mode proxy

# 永久啟用
warp-cli enable-always-on
```

```shell
https_proxy=socks5://127.0.0.1:11111 http_proxy=socks5://127.0.0.1:11111 go run main.go
```

2. 另一種方式是使用 Cloudflare Workers，請求由 Workers 轉發。

```javascript
export default {
	async fetch(request: Request): Promise {
		/**
		 * 將 `remote` 替換為你想要轉發請求的主機
		 */
		const remote = "https://example.com";

		return await fetch(remote, request);
	},
};
```

---
title: "Hide Within Cloudflare's Global Network"
date: 2024-08-01T14:35:24+08:00
menu:
  sidebar:
    name: "Hide Within Cloudflare's Global Network"
    identifier: cloudflare-hide-ip-in-cf
    weight: 10
tags: ["Links", "Cloudflare"]
categories: ["Links", "Cloudflare"]
hero: images/hero/cloudflare.svg
---

- [Hide Within Cloudflare's Global Network](https://dmesg.app/hide-in-cf.html)

1. One approach is to use Cloudflare WARP, running WARP in proxy mode instead of taking over global traffic.

```shell
warp-cli register
# WARP listens on local port 11111
warp-cli set-proxy-port 11111

# WARP proxy mode
warp-cli set-mode proxy

# Always on
warp-cli enable-always-on
```

```shell
https_proxy=socks5://127.0.0.1:11111 http_proxy=socks5://127.0.0.1:11111 go run main.go
```

2. Another approach is to use Cloudflare Workers, with requests forwarded by Workers.

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

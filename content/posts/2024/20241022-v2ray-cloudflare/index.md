---
title: "Relay V2Ray Traffic via Cloudflare"
date: 2024-10-22T09:24:08+08:00
menu:
  sidebar:
    name: "Relay V2Ray Traffic via Cloudflare"
    identifier: network-proxy-v2ray-forward-traffic-and-cloudflare-configuration
    weight: 10
tags: ["Links", "V2Ray", "Network", "Proxy"]
categories: ["Links", "V2Ray", "Network", "Proxy"]
hero: images/hero/network.png
---

- [Relay V2Ray Traffic via Cloudflare](https://233boy.com/v2ray/v2ray-cloudflare/)
- [The most convenient V2Ray one-click install script](https://233boy.com/v2ray/v2ray-script/)
- [V2Ray script DNS settings](https://233boy.com/v2ray/v2ray-dns/)
- [V2Ray script relay tutorial](https://233boy.com/v2ray/v2ray-dokodemo-door/)

## Install Script

```bash
bash <(wget -qO- -o- https://git.io/v2ray.sh)
```

## Preparation

Add a DNS record now. Name: `ai`, IPv4 address: `your VPS IP`. The proxy status must be off, so the cloud icon is gray.

Tip: You can use `v2ray ip` to view your VPS IP.

## Add Relay Configuration

Use `v2ray add ws ai.233boy.com` to add a vmess-ws-tls configuration; remember to replace `ai.233boy.com` with your domain.

This domain is the record you just added. For example, if your domain is 233boy.com and the name is ai, the domain is ai.233boy.com.

## Enable Relay

On the Cloudflare dashboard, click your domain, then choose `SSL/TLS` in the left sidebar.

Change the SSL/TLS encryption mode to `Full`.

Then in the left sidebar choose `DNS`.

Edit the record you added, enable the proxy (status is `Proxied`), the cloud icon is lit, and save.

After the cloud is lit, traffic goes through Cloudflare.

Reminder: Lit cloud means traffic is relayed by Cloudflare. Gray cloud means direct connection without Cloudflare.

## Get the Real Client IP

Some people have special needs, because with CF enabled the client IP in logs is CF's IP by default.

If you need the real client IP, update the Caddy config.

Find your Caddy config at `/etc/caddy/233boy/xxx.conf` (xxx is your domain).

The default config looks like this:

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333
    import /etc/caddy/233boy/xxx.conf.add
}
```

Update it to:

```
xxx:443 {
    reverse_proxy /56f7be67-809f-4f47-8cae-9bffa908adf5 127.0.0.1:2333 {
        header_up X-Real-IP {header.CF-Connecting-IP}
        header_up X-Forwarded-For {header.CF-Connecting-IP}
    }
    import /etc/caddy/233boy/xxx.conf.add
}
```

In principle, you only need to add the `header_up` options to use the CF forwarded IP.

After changes, restart Caddy: `v2ray restart caddy`

---

## DNS

Run `v2ray dns` to choose a DNS option.

```shell

Select DNS:

1) 1.1.1.1
2) 8.8.8.8
3) https://dns.google/dns-query
4) https://cloudflare-dns.com/dns-query
5) https://family.cloudflare-dns.com/dns-query
6) set
7) none

Choose [1-7]:
```

Note: options starting with https use DOH. DOH enables local query by default, which is DOH local mode (DOHL).

The `set` option lets you customize DNS.

The `none` option means no DNS configuration.

### google

Quickly set Google DNS: `v2ray dns 88`

Quickly set Google DNS DOH: `v2ray dns gg`

### cloudflare

Quickly set Cloudflare DNS: `v2ray dns 11`

Quickly set Cloudflare DNS DOH: `v2ray dns cf`

### nosex

Quickly set Cloudflare Family DNS DOH: `v2ray dns nosex`

Note: with this option, you won't be able to open certain adult sites (use it only if needed).

### set

Quickly set custom DNS to 9.9.9.9: `v2ray dns set 9.9.9.9`

Quickly set custom ADGUARD DNS DOH: `v2ray dns set https://dns.adguard-dns.com/dns-query`

Use `v2ray dns set` to enter a DNS value manually.

Or use `v2ray dns set 1.1.1.1` to set 1.1.1.1; you can replace it with any DNS you like.

### none

If you encounter any issues, use `v2ray dns none` to reset DNS settings.

If you want V2Ray to use system DNS, use this command too.

---

## Forwarding with Dokodemo-door

Suppose you have two VPS machines, A and B, and want to use A to forward traffic to B.

A common use case is that connections to A are better from within China, so you forward data from A to B, and then use B for other operations.

Or B can unlock certain online services but direct connections are poor, or the IP is even blocked, so you use A as a front relay.

The downside is that only TCP or UDP can be forwarded; TLS does not work.

### Add Configuration

First, add a V2Ray configuration on B, for example: `v2ray add tcp 233`

This adds a VMESS-TCP configuration with port 233.

If you already have a configuration, just note B's `IP` and the configuration `port`.

When forwarding with A, you must provide B's IP and the target port on B.

### door

Usage: `v2ray add door [port] [remote-addr] [remote-port]`

On A, run `v2ray add door`, then enter B's IP and port.

By default, the V2Ray script generates a random port. If you need a custom port, use `v2ray add door <custom-port>`.

### Test

Replace the address and port in B's config with A's IP and port.

This is B's config. For example, if you use v2rayN to import the config via URL, change the config's address and port to A's IP and the Dokodemo-door port.

See if it works.

### One-Click Add

Quickly add a relay configuration:

`v2ray add door 233 b.233boy.com 443`

Explanation: add a Dokodemo-door configuration. Port 233, target address b.233boy.com, target port 443.

Yes, the target address can also be a domain.

### A Clever Trick

Although the example above is for relaying V2Ray configs, you can also use it as a jump host for other tricks.

For example, forward traffic to 1.1.1.1 DNS: `v2ray add door 53 1.1.1.1 53`. That way your port 53 can also serve DNS.

Feel free to explore other uses.

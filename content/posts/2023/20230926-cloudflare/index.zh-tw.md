---
title: "Cloudflare Zero Trust"
date: 2023-09-26T09:01:00+08:00
description: 設定 Cloudflare Zero Trust
menu:
  sidebar:
    name: Cloudflare Zero Trust
    identifier: cloudflare-zero-trust
    weight: 10
tags: ["Links", "Cloudflare", "zero trust"]
categories: ["Links", "Cloudflare", "zero trust"]
hero: images/hero/cloudflare.svg
---

- [Connect private networks](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/connect-private-networks/)
- [Configure Local Domain Fallback](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/route-traffic/local-domains/)
- [Configure Split Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/exclude-traffic/split-tunnels/)
- [Traffic routing with WARP](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/exclude-traffic/)

### 1. 設定 Client

#### 建立裝置註冊規則

> 建立裝置註冊規則，用來決定哪些裝置可以加入 Zero Trust 組織。

##### 設定裝置註冊權限

1. 在 Zero Trust 中，前往 Settings > WARP Client > Device enrollment > Device enrollment permissions > Manage。
2. Rules > Policies > Add a rule > Include > Selector > Emails ending in > Value > @ruru910.com。

### 2. 透過 WARP 路由私有網路 IP

1. 在 Zero Trust 中，前往 Settings > WARP Client > Device settings > Profile settings > Profile name > Default > Configure。
2. 設定：
   1. Enabled: Captive portal detection, Mode switch, Allow device to leave organization, Allow updates。
   2. Service mode: Gateway with WARP。
   3. Local Domain Fallback > Manage > Domain > nas.ruru910.com。
   4. Split Tunnels: Exclude IPs and domains > Manage。
      - 刪除 nas.ruru910.com 的 IP range。

### 3. 用 Gateway 過濾網路流量

#### 1. 啟用 Gateway 代理

1. 在 Zero Trust 中，前往 Settings > Network。
   1. Gateway Logging: Capture all。
   2. Firewall: Proxy(TCP, UDP, ICMP), WARP to WARP, AV inspection。

#### 2. [建立 Zero Trust Policies](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/connect-private-networks/#create-zero-trust-policies)

1. 前往 Access > Applications > Add an application > Private Network > Application Type > Destination IP。
2. Value 輸入應用程式的 IP（例如 10.128.0.7）。
3. 修改 policy > identify > Selector > User Email > in > @ruru910.com。

---
title: "Cloudflare Zero Trust"
date: 2023-09-26T09:01:00+08:00
description: Setup Cloudflare Zero Trust
menu:
  sidebar:
    name: Cloudflare Zero Trust
    identifier: cloudflare-zero-trust
    weight: 10
tags: ["Cloudflare", "zero trust"]
categories: ["Cloudflare", "zero trust"]
hero: images/hero/cloudflare.svg
---

- [Connect private networks](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/connect-private-networks/)
- [Configure Local Domain Fallback](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/configure-warp/route-traffic/local-domains/)
- [Configure Split Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/exclude-traffic/split-tunnels/)
- [Traffic routing with WARP](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/exclude-traffic/)

### 1. Set up the client

#### Create device enrollment rules

> Create device enrollment rules to determine which devices can enroll to Zero Trust organization.

##### Set device enrollment permissions

1. In Zero Trust, go to Settings > WARP Client > Device enrollment > Device enrollment permissions > Manage.
2. Rules > Policies > Add a rule > Include > Selector > Emails ending in > Value > @ruru910.com.

### 2. Route private network IPs through WARP

1. In Zero Trust, go to Settings > WARP Client > Device settings > Profile settings > Profile name > Default > Configure.
2. Configure settings:
   1. Enabled: Captive portal detection, Mode switch, Allow device to leave organization, Allow updates.
   2. Service mode: Gateway with WARP.
   3. Local Domain Fallback > Manage > Domain > nas.ruru910.com.
   4. Split Tunnels: Exclude IPs and domains > Manage.
      - Delete the IP range of nas.ruru910.com.

### 3. Filter network traffic with Gateway

#### 1. Enable the Gateway proxy

1. In Zero Trust, go to Settings > Network.
   1. Gateway Logging: Capture all.
   2. Firewall: Proxy(TCP, UDP, ICMP), WARP to WARP, AV inspection.

#### 2. [Create Zero Trust policies](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/private-net/connect-private-networks/#create-zero-trust-policies)

1. Go to Access > Applications > Add an application > Private Network > Application Type > Destination IP.
2. For Value, enter the IP address for your application (for example, 10.128.0.7).
3. Modify policy > identify > Selector > User Email > in > @ruru910.com.

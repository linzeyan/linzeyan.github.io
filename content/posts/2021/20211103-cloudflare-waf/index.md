---
title: "Cloudflare Traffic sequence"
date: 2021-11-03T13:11:29+08:00
menu:
  sidebar:
    name: "Cloudflare Traffic sequence"
    identifier: cloudflare-waf-traffic-filter-sequence
    weight: 10
tags: ["Cloudflare", "WAF", "Network"]
categories: ["Cloudflare", "WAF", "Network"]
hero: images/hero/cloudflare.svg
---

### Traffic sequence

Traffic to your application runs through the following sequence on Cloudflare's edge:

1. DDoS
2. URL Rewrites
3. Page Rules
4. IP Access Rules
5. Bots
6. Firewall Rules
7. Rate Limiting
8. Managed Rules
9. Header Modification
10. Access
11. Workers

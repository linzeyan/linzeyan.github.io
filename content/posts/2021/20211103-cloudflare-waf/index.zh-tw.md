---
title: "Cloudflare 流量處理順序"
date: 2021-11-03T13:11:29+08:00
menu:
  sidebar:
    name: "Cloudflare 流量處理順序"
    identifier: cloudflare-waf-traffic-filter-sequence
    weight: 10
tags: ["Cloudflare", "WAF", "Network"]
categories: ["Cloudflare", "WAF", "Network"]
hero: images/hero/cloudflare.svg
---

### 流量處理順序

應用程式流量在 Cloudflare 邊緣節點會依下列順序處理：

1. DDoS
2. URL 重寫
3. 頁面規則
4. IP 存取規則
5. Bot 管理
6. 防火牆規則
7. 速率限制
8. 託管規則
9. 標頭修改
10. 存取控制
11. Workers

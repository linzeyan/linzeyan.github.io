---
title: "取得 GraphQL 結構資訊"
date: 2023-10-18T20:56:00+08:00
menu:
  sidebar:
    name: 取得 GraphQL 結構資訊
    identifier: graphql-schema-fetch-curl
    weight: 10
tags: ["GraphQL", "cURL"]
categories: ["GraphQL", "cURL"]
---

```bash
curl \
  -XPOST \
  -H "Content-Type: application/json" \
  -d '{"query":"{__schema { types { name enumValues { name } fields { name type {name kind enumValues { name } ofType { name kind ofType {name kind}}}}}}}"}' \
  https://example.com/graphql
```

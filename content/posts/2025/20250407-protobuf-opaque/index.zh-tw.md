---
title: "Go Protobuf：新的 Opaque API"
date: 2025-04-07T13:53:00+08:00
menu:
  sidebar:
    name: "Go Protobuf：新的 Opaque API"
    identifier: golang-protobuf-opaque-api
    weight: 10
tags: ["URL", "Go", "Protobuf"]
categories: ["URL", "Go", "Protobuf"]
hero: images/hero/go.svg
---

- [[译]Go Protobuf：新的 Opaque API](https://www.liwenzhou.com/posts/Go/protobuf-opaque/)

```diff
protoc --proto_path=. \
    --go_out=./ \
+    --go_opt=default_api_level=API_OPAQUE \
```

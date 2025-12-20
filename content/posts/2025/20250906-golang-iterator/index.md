---
title: "淺談 Go Iterator"
date: 2025-09-06T21:30:00+08:00
menu:
  sidebar:
    name: "淺談 Go Iterator"
    identifier: golang-iterator
    weight: 10
tags: ["URL", "Golang"]
categories: ["URL", "Golang"]
---

- [淺談 Go Iterator](https://ganhua.wang/go-iterator)

```go
type Seq[V any] func(yield func(V) bool)
type Seq2[K, V any] func(yield func(K, V) bool)
```

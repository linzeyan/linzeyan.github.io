---
title: "A Brief Look at Go Iterators"
date: 2025-09-06T21:30:00+08:00
menu:
  sidebar:
    name: "A Brief Look at Go Iterators"
    identifier: golang-iterator
    weight: 10
tags: ["Links", "Golang"]
categories: ["Links", "Golang"]
---

- [A Brief Look at Go Iterators](https://ganhua.wang/go-iterator)

```go
type Seq[V any] func(yield func(V) bool)
type Seq2[K, V any] func(yield func(K, V) bool)
```

---
title: "go-synctest"
date: 2025-11-07T14:06:00+08:00
menu:
  sidebar:
    name: "go-synctest"
    identifier: go-synctest
    weight: 10
tags: ["Links", "Go", "sync", "test"]
categories: ["Links", "Go", "sync", "test"]
hero: images/hero/go.svg
---

- [go-synctest](https://ganhua.wang/go-synctest)

```go
func TestAfterFunc(t *testing.T) {
    synctest.Test(t, func(*testing.T) {
        ctx, cancel := context.WithCancel(context.Background())

        called := false
        context.AfterFunc(ctx, func() { called = true })

        synctest.Wait() // Wait until all goroutines are blocked
        if called {
            t.Fatal("AfterFunc was called before cancel")
        }

        cancel()

        synctest.Wait() // Wait again
        if !called {
            t.Fatal("AfterFunc was not called after cancel")
        }
    })
}
```

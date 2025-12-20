---
title: "go-synctest"
date: 2025-11-07T14:06:00+08:00
menu:
  sidebar:
    name: "go-synctest"
    identifier: go-synctest
    weight: 10
tags: ["URL", "Go", "sync", "test"]
categories: ["URL", "Go", "sync", "test"]
hero: images/hero/go.svg
---

- [go-synctest](https://ganhua.wang/go-synctest)

```go
func TestAfterFunc(t *testing.T) {
    synctest.Test(t, func(*testing.T) {
        ctx, cancel := context.WithCancel(context.Background())

        called := false
        context.AfterFunc(ctx, func() { called = true })

        synctest.Wait() // 等到所有 goroutine 都卡住
        if called {
            t.Fatal("AfterFunc 在 cancel 前就被呼叫")
        }

        cancel()

        synctest.Wait() // 再等一次
        if !called {
            t.Fatal("AfterFunc 沒有在 cancel 後被呼叫")
        }
    })
}
```

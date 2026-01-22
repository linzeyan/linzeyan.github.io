---
title: "Go 程式碼重構：23 倍效能追擊"
date: 2022-06-07T13:42:07+08:00
menu:
  sidebar:
    name: "Go 程式碼重構：23 倍效能追擊"
    identifier: go-code-refactoring-the-23x-performance-hunt-156746b522f7
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go 程式碼重構：23 倍效能追擊](https://medium.com/@val_deleplace/go-code-refactoring-the-23x-performance-hunt-156746b522f7)

```bash
$ go test -bench=. -cpuprofile cpu.prof
$ go tool pprof -svg cpu.prof > cpu.svg
```

```bash
$ go test -bench=. -trace trace.out
$ go tool trace trace.out
```

---
title: "Gopher 需要知道的几个结构体骚操作"
date: 2022-01-03T15:08:31+08:00
menu:
  sidebar:
    name: "Gopher 需要知道的几个结构体骚操作"
    identifier: golang-some-struct-notes
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [Gopher 需要知道的几个结构体骚操作](https://mp.weixin.qq.com/s/A4m1xlFwh9pD0qy3p7ItSA)

#### NoCopy

```shell
$ go vet aaa.go
# command-line-arguments
./aaa.go:7:14: test passes lock by value: sync.WaitGroup contains sync.noCopy
./aaa.go:15:10: call of test copies lock value: sync.WaitGroup contains sync.noCopy
```

```go
type noCopy struct{}

type WaitGroup struct {
 noCopy noCopy

 // 64-bit value: high 32 bits are counter, low 32 bits are waiter count.
 // 64-bit atomic operations require 64-bit alignment, but 32-bit
 // compilers only guarantee that 64-bit fields are 32-bit aligned.
 // For this reason on 32 bit architectures we need to check in state()
 // if state1 is aligned or not, and dynamically "swap" the field order if
 // needed.
 state1 uint64
 state2 uint32
}
```

noCopy 定义非常简单，空结构体，zero size 不占用空间(前提是非结构体的最后一个字段，否则还要是有 8 byte 空间开销)

sync.WaitGroup 内嵌 noCopy 字段，防止 Cond 变量被复制

上面是 sync.WaitGroup 结构体的定义，同时注意 noCopy 是源码中不可导出的定义。如果用户代码也想实现 NoCopy 呢？可以参考 grpc DoNotCopy

```go
// DoNotCopy can be embedded in a struct to help prevent shallow copies.
// This does not rely on a Go language feature, but rather a special case
// within the vet checker.
type DoNotCopy [0]sync.Mutex
```

非常简单，Mutex 零长数组，不占用空间。由于 vet checker 会检测 Mutex，相当于替我们实现了 noCopy 功能

#### DoNotCompare

对于 struct 来讲，<mark>只有所有字段全部 comparable 的(不限大小写是否导出)，那么结构体才可以比较。同时只比较 non-blank 的字段</mark>

Slice, Map, Function 均是不可比较的，只与判断是否为 nil. 所以我们可以利用这两个特性，内嵌函数来实现不可比较，参考 protobuf DoNotCompare

```go
// DoNotCompare can be embedded in a struct to prevent comparability.
type DoNotCompare [0]func()
```

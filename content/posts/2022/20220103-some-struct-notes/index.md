---
title: "Struct Tricks Every Gopher Should Know"
date: 2022-01-03T15:08:31+08:00
menu:
  sidebar:
    name: "Struct Tricks Every Gopher Should Know"
    identifier: golang-some-struct-notes
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Struct Tricks Every Gopher Should Know](https://mp.weixin.qq.com/s/A4m1xlFwh9pD0qy3p7ItSA)

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

noCopy is very simple: an empty struct. It has zero size and takes no space (as long as it is not the last field of a struct; otherwise there is still an 8-byte space overhead).

sync.WaitGroup embeds noCopy to prevent the Cond variable from being copied.

The above is the definition of sync.WaitGroup. Note that noCopy is an unexported definition in the source code. If user code wants to implement NoCopy, you can refer to grpc DoNotCopy.

```go
// DoNotCopy can be embedded in a struct to help prevent shallow copies.
// This does not rely on a Go language feature, but rather a special case
// within the vet checker.
type DoNotCopy [0]sync.Mutex
```

It is very simple: a zero-length array of Mutex, which takes no space. Because vet checker inspects Mutex, it effectively implements noCopy for us.

#### DoNotCompare

For structs, <mark>only if all fields are comparable (regardless of whether they are exported) can the struct be compared. Also, only non-blank fields are compared.</mark>

Slice, Map, and Function are not comparable, and can only be checked for nil. So we can take advantage of this by embedding a function to make a struct non-comparable, as in protobuf DoNotCompare.

```go
// DoNotCompare can be embedded in a struct to prevent comparability.
type DoNotCompare [0]func()
```

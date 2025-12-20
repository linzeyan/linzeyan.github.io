---
title: "Golang tips"
date: 2023-09-26T22:15:00+08:00
menu:
  sidebar:
    name: Golang tips
    identifier: golang-tips
    weight: 10
tags: ["Go", "URL"]
categories: ["Go", "URL"]
hero: images/hero/go.svg
---

- [GO 编程模式：切片，接口，时间和性能](https://coolshell.cn/articles/21128.html)

Go 语言是一个高性能的语言，但并不是说这样我们就不用关心性能了，我们还是需要关心的。下面是一个在编程方面和性能相关的提示。

- 如果需要把数字转字符串，使用 `strconv.Itoa()` 会比 `fmt.Sprintf()` 要快一倍左右
- 尽可能地避免把 `String` 转成`[]Byte` 。这个转换会导致性能下降。
- 如果在 for-loop 里对某个 slice 使用 `append()`请先把 slice 的容量很扩充到位，这样可以避免内存重新分享以及系统自动按 2 的 N 次方幂进行扩展但又用不到，从而浪费内存。
- 使用 `StringBuffer` 或是 `StringBuild` 来拼接字符串，会比使用 `+` 或 `+=` 性能高三到四个数量级。
- 尽可能的使用并发的 go routine，然后使用 `sync.WaitGroup` 来同步分片操作
- 避免在热代码中进行内存分配，这样会导致 gc 很忙。尽可能的使用 `sync.Pool` 来重用对象。
- 使用 lock-free 的操作，避免使用 mutex，尽可能使用 `sync/Atomic` 包。 （关于无锁编程的相关话题，可参看《[无锁队列实现](https://coolshell.cn/articles/8239.html)》或《[无锁 Hashmap 实现](https://coolshell.cn/articles/9703.html)》）
- 使用 I/O 缓冲，I/O 是个非常非常慢的操作，使用 `bufio.NewWrite()` 和 `bufio.NewReader()` 可以带来更高的性能。
- 对于在 for-loop 里的固定的正则表达式，一定要使用 `regexp.Compile()` 编译正则表达式。性能会得升两个数量级。
- 如果你需要更高性能的协议，你要考虑使用 [protobuf](https://github.com/golang/protobuf) 或 [msgp](https://github.com/tinylib/msgp) 而不是 JSON，因为 JSON 的序列化和反序列化里使用了反射。
- 你在使用 map 的时候，使用整型的 key 会比字符串的要快，因为整型比较比字符串比较要快。

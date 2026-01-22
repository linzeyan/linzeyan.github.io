---
title: "Golang Tips"
date: 2023-09-26T22:15:00+08:00
menu:
  sidebar:
    name: Golang Tips
    identifier: golang-tips
    weight: 10
tags: ["Go", "Links"]
categories: ["Go", "Links"]
hero: images/hero/go.svg
---

- [Go Programming Patterns: Slices, Interfaces, Time, and Performance](https://coolshell.cn/articles/21128.html)

Go is a high-performance language, but that does not mean we can ignore performance. Here are some tips related to programming and performance.

- If you need to convert numbers to strings, `strconv.Itoa()` is about twice as fast as `fmt.Sprintf()`.
- Avoid converting `String` to `[]Byte` where possible. This conversion hurts performance.
- If you use `append()` on a slice inside a for-loop, expand the slice capacity ahead of time to avoid reallocations and automatic growth by powers of two, which can waste memory.
- Use `StringBuffer` or `StringBuild` to concatenate strings; they are three to four orders of magnitude faster than `+` or `+=`.
- Use concurrent goroutines where possible, and use `sync.WaitGroup` to synchronize concurrent work.
- Avoid allocating in hot paths; it makes the GC busy. Use `sync.Pool` to reuse objects.
- Use lock-free operations and avoid mutexes when possible; use `sync/Atomic`. (See [Lock-Free Queue Implementation](https://coolshell.cn/articles/8239.html) or [Lock-Free Hashmap Implementation](https://coolshell.cn/articles/9703.html).)
- Use I/O buffering; I/O is very slow. `bufio.NewWrite()` and `bufio.NewReader()` improve performance.
- For fixed regex patterns in a for-loop, use `regexp.Compile()` to precompile; it improves performance by two orders of magnitude.
- If you need higher-performance protocols, consider [protobuf](https://github.com/golang/protobuf) or [msgp](https://github.com/tinylib/msgp) instead of JSON, because JSON serialization/deserialization uses reflection.
- When using maps, integer keys are faster than string keys because integer comparisons are faster.

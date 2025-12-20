---
title: "使用Go语言解析二进制数据踩坑总结"
date: 2023-01-20T13:48:27+08:00
menu:
  sidebar:
    name: "使用Go语言解析二进制数据踩坑总结"
    identifier: golang-parse-binary-data
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [使用 Go 语言解析二进制数据踩坑总结](https://tao.zz.ac/go/parse-binary-data.html)

```go
for {
  buf := make([]byte, bufSize)
  n, err := r.Read(buf)
  if err == io.EOF {
    return
  } else if err != nil {
    aerr.Store(err)
    return
  }
  ch <- buf[:n]
}
```

> 当 err 的值为 io.EOF 时直接返回了。这是最可能出问题的地方。仔细阅读函数文档发现：
>
> > Callers should always process the n > 0 bytes returned before considering the error err. Doing so correctly handles I/O errors that happen after reading some bytes and also both of the allowed EOF behaviors.
>
> 所以程序必须先处理 n > 0 的情况，然后再处理 err != nil 的情况！这跟我之前的印象不相符。因为一般来说，当 err 非空时，前面的返回数据一般都是空值。但 io.Reader 并不是这样。

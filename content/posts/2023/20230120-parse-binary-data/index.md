---
title: "Pitfalls When Parsing Binary Data in Go"
date: 2023-01-20T13:48:27+08:00
menu:
  sidebar:
    name: "Pitfalls When Parsing Binary Data in Go"
    identifier: golang-parse-binary-data
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Pitfalls When Parsing Binary Data in Go](https://tao.zz.ac/go/parse-binary-data.html)

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

> The code returns immediately when err is io.EOF, which is the most likely problem. The docs say:
>
> > Callers should always process the n > 0 bytes returned before considering the error err. Doing so correctly handles I/O errors that happen after reading some bytes and also both of the allowed EOF behaviors.
>
> So the program must handle n > 0 first, and then handle err != nil. This differs from the usual assumption that a non-nil err implies no data. io.Reader does not behave that way.

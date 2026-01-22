---
title: "How to Choose a Go File Reading Approach"
date: 2022-03-29T16:15:34+08:00
menu:
  sidebar:
    name: "How to Choose a Go File Reading Approach"
    identifier: go-file-reading-scheme
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [How to Choose a Go File Reading Approach](https://mp.weixin.qq.com/s/Z-19Yj8Je7Wb9bqvMR35Cg)

> Go provides one-shot methods for reading file content: `os.ReadFile` and `ioutil.ReadFile`. Starting from Go 1.16, `ioutil.ReadFile` is equivalent to `os.ReadFile`.
>
> The pros and cons of loading a file in one shot are obvious: it reduces IO operations, but it loads the entire file into memory. For large files, this risks running out of memory.

#### Read line by line

In Go, the bufio.Reader type provides ReadLine(), but in practice we more often use ReadBytes('\n') or ReadString('\n').

```go
func ReadLines(filename string) {
 fi, err := os.Open(filename)
 if err != nil{
  panic(err)
 }
 defer fi.Close()
 reader := bufio.NewReader(fi)
 for {
  _, err = reader.ReadString('\n')
  if err != nil {
   if err == io.EOF {
    break
   }
   panic(err)
  }
 }
}
```

#### Chunked reading

Chunked reading is also called segmented reading. It is easy to understand: we split the content into chunks and read a fixed-size block each time. Here, we set the chunk size to 4KB.

```go
func ReadChunk(filename string) {
 f, err := os.Open(filename)
 if err != nil {
  panic(err)
 }
 defer f.Close()
 buf := make([]byte, 4*1024)
 r := bufio.NewReader(f)
 for {
  _, err = r.Read(buf)
  if err != nil {
   if err == io.EOF {
    break
   }
   panic(err)
  }
 }
}
```

#### result

```shell
BenchmarkOsReadFile4KB-8           92877             12491 ns/op
BenchmarkOsReadFile4MB-8            1620            744460 ns/op
BenchmarkOsReadFile4GB-8               1        7518057733 ns/op
signal: killed

BenchmarkReadLines4KB-8            90846             13184 ns/op
BenchmarkReadLines4MB-8              493           2338170 ns/op
BenchmarkReadLines4GB-8                1        3072629047 ns/op
BenchmarkReadLines16GB-8               1        12472749187 ns/op

BenchmarkReadChunk4KB-8            99848             12262 ns/op
BenchmarkReadChunk4MB-8              913           1233216 ns/op
BenchmarkReadChunk4GB-8                1        2095515009 ns/op
BenchmarkReadChunk16GB-8               1        8547054349 ns/op
```

Under the test conditions in this article (1KB per line), for small 4KB reads, the differences among the three methods are not large. For MB-level reads, full read is the fastest, but chunked reading is not far behind. For GB-level reads, chunked reading becomes the fastest.

One more thing to note: with full-file loading, a 16 GB file (on a machine with 8GB RAM) runs out of memory and cannot complete.

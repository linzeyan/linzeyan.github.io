---
title: "怎么选择 Go 文件读取方案"
date: 2022-03-29T16:15:34+08:00
menu:
  sidebar:
    name: "怎么选择 Go 文件读取方案"
    identifier: go-file-reading-scheme
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [怎么选择 Go 文件读取方案](https://mp.weixin.qq.com/s/Z-19Yj8Je7Wb9bqvMR35Cg)

> Go 提供了可一次性读取文件内容的方法：`os.ReadFile` 与 `ioutil.ReadFile`。在 Go 1.16 开始，`ioutil.ReadFile` 就等价于 `os.ReadFile`。
>
> 一次性加载文件的优缺点非常明显，它能减少 IO 次数，但它会将文件内容都加载至内存中，对于大文件，存在内存撑爆的风险。

#### 逐行读取

Go 中 bufio.Reader 对象提供了一个 ReadLine() 方法，但其实我们更多地是使用 ReadBytes('\n') 或者 ReadString('\n') 代替。

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

#### 块读取

块读取也称为分片读取，这也很好理解，我们可以将内容分成一块块的，每次读取指定大小的块内容。这里，我们将块大小设置为 4KB。

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

在本文的测试条件下（每行数据 1KB），对于小对象 4KB 的读取，三种方式差距并不大；在 MB 级别的读取中，直接加载最快，但块读取也慢不了多少；上了 GB 后，块读取方式会最快。

且有一点可以注意到的是，在整个文件加载的方式中，对于 16 GB 的文件数据（测试机器运行内存为 8GB），会内存耗尽出错，没法执行。

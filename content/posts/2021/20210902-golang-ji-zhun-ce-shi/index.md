---
title: "Golang benchmarks"
date: 2021-09-02T12:50:33+08:00
menu:
  sidebar:
    name: "Golang benchmarks"
    identifier: golang-testing-ji-zhun-ce-shi
    weight: 10
tags: ["Links", "Go", "Benchmark", "Testing"]
categories: ["Links", "Go", "Benchmark", "Testing"]
hero: images/hero/go.svg
---

- [Golang benchmarks](https://mp.weixin.qq.com/s?__biz=MzkxNzAzNDA3Ng==&mid=2247485595&idx=1&sn=9981e6103a6b33cc3a06be0781a2bf10&chksm=c1478da8f63004be44a8c84941280f3888d4e5a2120a4288ed1a21f8a1a82fe65d719c31bae6#rd)

#### Basics

> Benchmarks are used for performance testing. Functions should import the testing package and define functions that start with Benchmark. The parameter type is testing.B, and the target function is called repeatedly inside the benchmark loop.

```shell
➜  go test -bench=. -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib-12              250           4682682 ns/op
PASS
ok      pkg06   1.875s
➜  go test -bench=. -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib-12              249           4686452 ns/op               0 B/op          0 allocs/op
PASS
ok      pkg06   1.854s
```

#### How bench works

- The benchmark function keeps running until `b.N` is no longer valid; it is the number of iterations.
- `b.N` starts at `1`. If the benchmark completes within `1` second (default), `b.N` increases and the benchmark runs again.
- `b.N` increases in the sequence `1,2,5,10,20,50,...` and the benchmark reruns.
- The result above means it ran `250` times in 1 second, with each run taking `4682682 ns`.
- The `-12` suffix relates to `GOMAXPROCS`. The default value is the number of CPUs visible to the Go process at startup. You can change it with `-cpu`, and pass multiple values to run multiple benchmarks.

#### Run with multiple CPU counts

```shell
➜  go test -bench=. -cpu=1,2,4  -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib                 244           4694667 ns/op               0 B/op          0 allocs/op
BenchmarkFib-2               255           4721201 ns/op               0 B/op          0 allocs/op
BenchmarkFib-4               256           4756392 ns/op               0 B/op          0 allocs/op
PASS
ok      pkg06   5.826s
```

#### Run benchmarks multiple times with count

> Due to CPU throttling, memory locality, background work, GC activity, etc., a single run may be noisy. It is common to run benchmarks multiple times.

```shell
➜  go test -bench=. -count=10  -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib-12              217           5993577 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              246           5065577 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              244           4955397 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              255           4689529 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              254           4879802 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              254           4691213 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              255           4772108 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              240           4724141 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              255           4717087 ns/op               0 B/op          0 allocs/op
BenchmarkFib-12              255           4787803 ns/op               0 B/op          0 allocs/op
PASS
ok      pkg06   18.166s
```

#### benchtime: specify duration

> For slower functions, you can use -benchtime to run longer and collect more samples.

```shell
➜  go test -bench=. -benchtime=5s  -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib-12             1128           4716535 ns/op               0 B/op          0 allocs/op
PASS
ok      pkg06   7.199s
```

#### ResetTimer

> If the benchmark includes setup work like initialization, reset the timer before the actual benchmark to get more accurate results.

```go
package pkg06

import (
 "testing"
 "time"
)

func BenchmarkFib(b *testing.B) {
 time.Sleep(3 * time.Second)
 b.ResetTimer()
 for n := 0; n < b.N; n++ {
  fib(30)
 }
}
```

```shell
➜  go test -bench=. -benchtime=5s  -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg06
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkFib-12             1239           4712413 ns/op               0 B/op          0 allocs/op
PASS
ok      pkg06   16.122s
```

#### benchmem shows memory usage

- For example, compare a slice initialized with a large cap vs dynamic growth.

```go
package pkg08

import (
 "math/rand"
 "testing"
 "time"
)

// 指定大的cap的切片
func generateWithCap(n int) []int {
 rand.Seed(time.Now().UnixNano())
 nums := make([]int, 0, n)
 for i := 0; i < n; i++ {
  nums = append(nums, rand.Int())
 }
 return nums
}

// 动态扩容的slice
func generateDynamic(n int) []int {
 rand.Seed(time.Now().UnixNano())
 nums := make([]int, 0)
 for i := 0; i < n; i++ {
  nums = append(nums, rand.Int())
 }
 return nums
}

func benchmarkGenerate(i int, b *testing.B) {
 for n := 0; n < b.N; n++ {
  generateDynamic(i)
 }
}

func BenchmarkGenerateDynamic1000(b *testing.B)     { benchmarkGenerate(1000, b) }
func BenchmarkGenerateDynamic10000(b *testing.B)    { benchmarkGenerate(10000, b) }
func BenchmarkGenerateDynamic100000(b *testing.B)   { benchmarkGenerate(100000, b) }
func BenchmarkGenerateDynamic1000000(b *testing.B)  { benchmarkGenerate(1000000, b) }
func BenchmarkGenerateDynamic10000000(b *testing.B) { benchmarkGenerate(10000000, b) }
```

```shell
➜  go test -bench=. -benchmem -run=none
goos: darwin
goarch: amd64
pkg: pkg08
cpu: Intel(R) Core(TM) i7-8850H CPU @ 2.60GHz
BenchmarkGenerateDynamic1000-12            39540             26557 ns/op           16376 B/op         11 allocs/op
BenchmarkGenerateDynamic10000-12            5452            210894 ns/op          386296 B/op         20 allocs/op
BenchmarkGenerateDynamic100000-12            572           2106325 ns/op         4654341 B/op         30 allocs/op
BenchmarkGenerateDynamic1000000-12            48          23070939 ns/op        45188416 B/op         40 allocs/op
BenchmarkGenerateDynamic10000000-12            5         212567041 ns/op        423503110 B/op        50 allocs/op
PASS
ok      pkg08   9.686s
```

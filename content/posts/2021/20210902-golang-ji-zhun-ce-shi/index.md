---
title: "Golang基准测试"
date: 2021-09-02T12:50:33+08:00
menu:
  sidebar:
    name: "Golang基准测试"
    identifier: golang-testing-ji-zhun-ce-shi
    weight: 10
tags: ["URL", "Go", "Benchmark", "Testing"]
categories: ["URL", "Go", "Benchmark", "Testing"]
hero: images/hero/go.svg
---

- [Golang 基准测试](https://mp.weixin.qq.com/s?__biz=MzkxNzAzNDA3Ng==&mid=2247485595&idx=1&sn=9981e6103a6b33cc3a06be0781a2bf10&chksm=c1478da8f63004be44a8c84941280f3888d4e5a2120a4288ed1a21f8a1a82fe65d719c31bae6#rd)

#### 基本使用

> 基准测试常用于代码性能测试，函数需要导入 testing 包，并定义以 Benchmark 开头的函数， 参数为 testing.B 指针类型，在测试函数中循环调用函数多次

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

#### bench 的工作原理

- 基准测试函数会被一直调用直到 `b.N` 无效，它是基准测试循环的次数
- `b.N` 从 `1` 开始，如果基准测试函数在 `1` 秒内就完成 (默认值)，则 `b.N` 增加，并再次运行基准测试函数
- `b.N` 的值会按照序列 `1,2,5,10,20,50,...` 增加，同时再次运行基准测测试函数
- 上述结果解读代表 `1` 秒内运行了 `250` 次，每次 `4682682 ns`
- `-12` 后缀和用于运行次测试的 `GOMAXPROCS` 值有关。与 `GOMAXPROCS` 一样，此数字默认为启动时 Go 进程可见的 CPU 数。可以使用 `-cpu` 标识更改此值，可以传入多个值以列表形式来运行基准测试

#### 传入 cpu num 进行测试

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

#### count 多次运行基准测试

> 因为热缩放、内存局部性、后台处理、gc 活动等等会导致单次的误差，所以一般会进行多次测试

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

#### benchtime 指定运行秒数

> 有的函数比较慢，为了更精确的结果，可以通过-benchtime 标志指定运行时间，从而使它运行更多次

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

#### ResetTimer 重置定时器

> 能在真正测试之前还需要做很多例如初始化等工作，这时可以在需要测试的函数执行之初添加一个重置定时器的功能，这样最终得到的时间就更为精确

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

#### benchmem 展示内存消耗

- 例如测试大 cap 的切片，直接用 cap 初始化和 cap 动态扩容进行对比

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

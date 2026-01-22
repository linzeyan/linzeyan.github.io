---
title: "[Translated] Go inline strategy and limitations"
date: 2021-08-14T20:33:41+08:00
menu:
  sidebar:
    name: "[Translated] Go inline strategy and limitations"
    identifier: go-inlining-strategy-limitation
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [[Translated] Go inline strategy and limitations](https://www.pengrl.com/p/20028/)
- [Go: Inlining Strategy & Limitation](https://medium.com/a-journey-with-go/go-inlining-strategy-limitation-6b6d7fc3b1be)
- [Visualizing memory management in Golang](https://deepu.tech/memory-management-in-golang/)
- [Understanding Allocations in Go](https://medium.com/eureka-engineering/understanding-allocations-in-go-stack-heap-memory-9a2631b5035d)

```go
package main

import "fmt"

func main() {
	n := []float32{120.4, -46.7, 32.50, 34.65, -67.45}
	fmt.Printf("The total is %.02f\n", sum(n))
}

func sum(s []float32) float32 {
	var t float32
	for _, v := range s {
		if t < 0 {
			t = add(t, v)
		} else {
			t = sub(t, v)
		}
	}
	return t
}

func add(a, b float32) float32 { return a + b }
func sub(a, b float32) float32 { return a - b }
```

Run with `-gflags="-m"` to show which functions are inlined.

```shell
./op.go:3:6: can inline add
./op.go:7:6: can inline sub
./main.go:16:11: inlining call to sub
./main.go:14:11: inlining call to add
./main.go:7:12: inlining call to fmt.Printf
```

You can see that add is inlined. But why is sum not inlined? With `-gflags="-m -m"` you can see the reason:

```shell
./main.go:10:6: cannot inline sum: unhandled op RANGE
```

Go does not inline functions that contain loops. In fact, functions containing any of the following are not inlined:

- closure calls
- select
- for
- defer
- goroutines created with the go keyword

There are additional limits. When parsing the AST, Go allocates a budget of 80 nodes for inlining. Each node consumes one unit of budget.

For example, `a = a + 1` contains 5 nodes: AS, NAME, ADD, NAME, LITERAL.

If a function exceeds the budget, it cannot be inlined. For a more complex add function, you might see:

```shell
/op.go:3:6: cannot inline add: function too complex: cost 104 exceeds budget 80
```

#### Performance gains from inlining

Inlining is an important technique in high-performance programming. Every function call has overhead: stack frame setup and register reads/writes. Inlining removes that overhead.

That said, copying the function body increases binary size. Here is a benchmark comparison of inline vs non-inline:

```shell
name                     old time/op    new time/op    delta
BinaryTree17-8              2.34s ± 2%     2.43s ± 3%   +3.77%
Fannkuch11-8                2.21s ± 1%     2.26s ± 1%   +2.01%
FmtFprintfEmpty-8          33.6ns ± 6%    35.2ns ± 3%   +4.85%
FmtFprintfString-8         55.3ns ± 3%    62.8ns ± 1%  +13.48%
FmtFprintfInt-8            63.1ns ± 3%    70.0ns ± 2%  +11.04%
FmtFprintfIntInt-8         95.9ns ± 3%   102.3ns ± 3%   +6.68%
FmtFprintfPrefixedInt-8     105ns ± 4%     111ns ± 1%   +5.83%
FmtFprintfFloat-8           165ns ± 4%     175ns ± 1%   +6.16%
FmtManyArgs-8               405ns ± 2%     427ns ± 0%   +5.38%
GobDecode-8                4.69ms ± 2%    4.78ms ± 4%   +1.77%
GobEncode-8                3.84ms ± 2%    3.93ms ± 3%     ~
Gzip-8                      210ms ± 3%     208ms ± 1%     ~
Gunzip-8                   28.1ms ± 7%    29.4ms ± 1%   +4.69%
HTTPClientServer-8         70.0µs ± 2%    70.9µs ± 1%   +1.21%
JSONEncode-8               7.28ms ± 5%    7.00ms ± 2%   -3.91%
JSONDecode-8               33.9ms ± 3%    33.1ms ± 1%   -2.32%
Mandelbrot200-8            3.74ms ± 0%    3.74ms ± 1%     ~
```

Inlining usually improves performance by about 5% to 6%.

#### Memory Allocation

- Tiny(size < 16B): Objects of size less than 16 bytes are allocated using the mcache's tiny allocator. This is efficient and multiple tiny allocations are done on a single 16-byte block.
- Small(size 16B ~ 32KB): Objects of size between 16 bytes and 32 Kilobytes are allocated on the corresponding size class(mspan) on mcache of the P where the G is running.

In both tiny and small allocation if the mspan's list is empty the allocator will obtain a run of pages from the mheap to use for the mspan. If the mheap is empty or has no page runs large enough then it allocates a new group of pages (at least 1MB) from the OS.

- Large(size > 32KB): Objects of size greater than 32 kilobytes are allocated directly on the corresponding size class of mheap. If the mheap is empty or has no page runs large enough then it allocates a new group of pages (at least 1MB) from the OS.

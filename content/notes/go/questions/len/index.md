---
title: Len
weight: 120
menu:
  notes:
    name: Len
    identifier: notes-go-questions-len
    parent: notes-go-questions
    weight: 20
---

{{< note title="len" >}}

```go
package main

func main() {
	var x *struct {
		s [][32]byte
	}

	println(len(x.s[99]))
}
```
- A. panic
- B. compilation error
- C. 32
- D. 0

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="len1" >}}

```go
package main

const s = "Go101.org"

// len(s) == 9
// 1 << 9 == 512
// 512 / 128 == 4

var a byte = 1 << len(s) / 128
var b byte = 1 << len(s[:]) / 128

func main() {
	println(a, b)
}
```
- A: 0 0
- B: 0 4
- C: 4 0
- D: 4 4

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="len2" >}}

```go
package main

var s = "Go101.org"

// len(s) == 9
// 1 << 9 == 512
// 512 / 128 == 4

var a byte = 1 << len(s) / 128
var b byte = 1 << len(s[:]) / 128

func main() {
	println(a, b)
}
```
- A: 0 0
- B: 0 4
- C: 4 0
- D: 4 4

<details>
<summary>Answer</summary>
<pre>
<code>A
</code></pre></details>
{{< /note >}}

---
title: Slice
weight: 120
menu:
  notes:
    name: Slice
    identifier: notes-go-questions-slice
    parent: notes-go-questions
    weight: 20
---

{{< note title="slice" >}}

```go
package main

import (
	"fmt"
)

func main() {
	var s1 []int
	var s2 = []int{}
	if __ == nil {
		fmt.Println("nil slice")
	}
	if __ != nil {
		fmt.Println("empty slice")
	}
}
```
- A. s1, s2
- B. s2, s1
- C. s1, s1
- D. s2, s2

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/S_Q4w6NMAoU" target="_blank">Try it</a>
<code>A
</code></pre></details>
{{< /note >}}



{{< note title="slice1" >}}

```go
package main

import (
	"fmt"
)

func main() {
	s := [3]int{1, 2, 3}
	a := s[:0]
	b := s[:2]
	c := s[1:2:cap(s)]
	fmt.Println(len(a), cap(a))
	fmt.Println(len(b), cap(b))
	fmt.Println(len(c), cap(c))
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/hpZ3VyWv-Pz" target="_blank">Try it</a>
<code class="language-shell">0 3
2 3
1 2
</code></pre></details>
{{< /note >}}



{{< note title="slice2" >}}

```go
package main

import "fmt"

func main() {
	s1 := []int{1, 2, 3}
	s2 := s1[1:]
	s2[1] = 4
	fmt.Println(s1)
	s2 = append(s2, 5, 6, 7)
	fmt.Println(s1)
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/H-1Jf-LwUg4" target="_blank">Try it</a>
<code class="language-shell">[1 2 4]
[1 2 4]
</code></pre></details>
{{< /note >}}

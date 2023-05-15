---
title: Iota
weight: 120
menu:
  notes:
    name: Iota
    identifier: notes-go-questions-iota
    parent: notes-go-questions
    weight: 20
---

{{< note title="iota" >}}

```go
package main

import "fmt"

const (
	x = iota
	_
	y
	z = "zz"
	k
	p = iota
)

func main() {
	fmt.Println(x, y, z, k, p)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0 2 zz zz 5
</code></pre></details>
{{< /note >}}



{{< note title="iota1" >}}

```go
package main

import "fmt"

const (
	a = iota
	b = iota
)

const (
	name = "name"
	c    = iota
	d    = iota
)

func main() {
	fmt.Println(a, b, c, d)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0 1 1 2
</code></pre></details>
{{< /note >}}

---
title: Variable
weight: 120
menu:
  notes:
    name: Variable
    identifier: notes-go-questions-variable
    parent: notes-go-questions
    weight: 20
---

{{< note title="variable" >}}

- A. p.name
- B. (&p).name
- C. (*p).name
- D. p->name

<details>
<summary>Answer</summary>
<pre>
<code>AC
</code></pre></details>
{{< /note >}}



{{< note title="variable1" >}}
```go
package main

import (
	"fmt"
)

func main() {
	var ans float64 = 15 + 25 + 5.2
	fmt.Println(ans)
}
```
- A. 45
- B. 45.0
- C. 45.2
- D. compliation error

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/VCR1yAY32nG" target="_blank">Try it</a>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="variable2" >}}
```go
package main

import (
	"fmt"
)

func main() {
	var ans float64 = 3 / 2
	fmt.Println(ans)
}
```
- A. 1.5
- B. 1
- C. 0
- D. compliation error

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/SXwEiV0FUWJ" target="_blank">Try it</a>
<code>B
</code></pre></details>
{{< /note >}}



{{< note title="variable3" >}}
```go
package main

func main() {
	const a int8 = -1
	var b int8 = -128 / a

	println(b)
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/Th1vvvhoDjR" target="_blank">Try it</a>
<code class="language-shell">compliation error
-128 / a (constant 128 of type int8) overflows int8
</code></pre></details>
{{< /note >}}



{{< note title="variable4" >}}
```go
package main

func main() {
	var a int8 = -1
	var b int8 = -128 / a

	println(b)
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/Z8N_FB4szWY" target="_blank">Try it</a>
<code class="language-shell">-128
</code></pre></details>
{{< /note >}}



{{< note title="variable5" >}}

```go
package main

import "fmt"

type MyInt1 int
type MyInt2 = int

func main() {
	var i int =0
	var i1 MyInt1 = i
	var i2 MyInt2 = i
	fmt.Println(i1, i2)
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/Q25PLVaAOfd" target="_blank">Try it</a>
<code class="language-shell">compilation error
cannot use i (variable of type int) as MyInt1 value in variable declaration
</code></pre></details>
{{< /note >}}



{{< note title="variable6" >}}

```go
package main

import "fmt"

func main() {
	const X = 7.0
	var x interface{} = X
	if y, ok := x.(int); ok {
		fmt.Println(y)
	} else {
		fmt.Println(int(y))
	}
}
```
- A. 7
- B. 7.0
- C. 0
- D. compilation error

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/lKmlfL6X6Qu" target="_blank">Try it</a>
<code>C
</code></pre></details>
{{< /note >}}

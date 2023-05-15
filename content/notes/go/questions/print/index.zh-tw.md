---
title: Print
weight: 120
menu:
  notes:
    name: Print
    identifier: notes-go-questions-print
    parent: notes-go-questions
    weight: 20
---

{{< note title="print" >}}

```go
package main

import "fmt"

type T struct {
	x int
}

func (t T) String() string { return "boo" }

func main() {
	t := T{123}
	fmt.Printf("%v\n", t)
	fmt.Printf("%#v\n", t)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">boo
main.T{x:123}
</code></pre></details>
{{< /note >}}



{{< note title="print1" >}}

```go
package main

import (
	"fmt"
)

func f(a ...int) {
	fmt.Printf("%#v\n", a)
}

func main() {
	f()
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">[]int(nil)
</code></pre></details>
{{< /note >}}

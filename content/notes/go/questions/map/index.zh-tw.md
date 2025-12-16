---
title: Map
weight: 120
menu:
  notes:
    name: Map
    identifier: notes-go-questions-map
    parent: notes-go-questions
    weight: 20
---

{{< note title="map" >}}

```go
package main

import "fmt"

type Student struct {
  Name string
}

var list map[string]Student

func main() {

	list = make(map[string]Student)

	student := Student{"Aceld"}

	list["student"] = student
	list["student"].Name = "LDB"

	fmt.Println(list["student"])
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/gkPDhQyDAQW" target="_blank">Try it</a>
<code class="language-shell">compilation error
cannot assign to struct field list["student"].Name in map
</code></pre></details>
{{< /note >}}



{{< note title="map1" >}}

```go
package main

func main() {
	m := make(map[int]int, 3)
	x := len(m)
	m[1] = m[1]
	y := len(m)
	println(x, y)
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/OM5SjB_pob2" target="_blank">Try it</a>
<code class="language-shell">0 1
</code></pre></details>
{{< /note >}}

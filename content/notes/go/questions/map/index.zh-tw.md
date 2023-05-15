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
<pre>
<code class="language-shell">compilation error
cannot assign to struct field list["student"].Name in map
</code></pre></details>
{{< /note >}}

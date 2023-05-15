---
title: Array
weight: 120
menu:
  notes:
    name: Array
    identifier: notes-go-questions-array
    parent: notes-go-questions
    weight: 20
---

{{< note title="array" >}}

```go
package main

import (
    "fmt"
)

func main() {
    a := [5]int{1, 2, 3, 4, 5}
    t := a[3:4:4]
    fmt.Println(t[0])
}
```
- A. 3
- B. 4
- C. compilation error

<details>
<summary>Answer</summary>
<pre>
<code>B
</code></pre></details>
{{< /note >}}

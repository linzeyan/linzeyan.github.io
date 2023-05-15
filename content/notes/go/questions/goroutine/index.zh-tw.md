---
title: Goroutine
weight: 120
menu:
  notes:
    name: Goroutine
    identifier: notes-go-questions-goroutine
    parent: notes-go-questions
    weight: 20
---

{{< note title="goroutine" >}}

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch1 := make(chan int)
	go fmt.Println(<-ch1)
	ch1 <- 5
	time.Sleep(1 * time.Second)
}
```
- A. 5
- B. deadlock
- C. compilation error

<details>
<summary>Answer</summary>
<pre>
<code>B
</code></pre></details>
{{< /note >}}

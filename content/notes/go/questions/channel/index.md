---
title: Channel
weight: 120
menu:
  notes:
    name: Channel
    identifier: notes-go-questions-channel
    parent: notes-go-questions
    weight: 20
---

{{< note title="channel" >}}

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	ch := make(chan int, 1000)
	go func() {
		for i := 0; i < 10; i++ {
			ch <- i
		}
	}()
	go func() {
		for {
			a, ok := <-ch
			if !ok {
				fmt.Println("close")
				return
			}
			fmt.Println("a: ", a)
		}
	}()
	close(ch)
	fmt.Println("ok")
	time.Sleep(time.Second * 100)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">ok
panic: send on closed channel
</code></pre></details>
{{< /note >}}



{{< note title="channel1" >}}

```go
package main

import (
	"fmt"
)

func main() {
	c := make(chan int)
	close(c)
	val, _ := <-c
	fmt.Println(val)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0
</code></pre></details>
{{< /note >}}

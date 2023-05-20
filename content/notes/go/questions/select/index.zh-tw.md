---
title: Select
weight: 120
menu:
  notes:
    name: Select
    identifier: notes-go-questions-select
    parent: notes-go-questions
    weight: 20
---

{{< note title="select" >}}

```go
package main

import "sync"

func main() {
	var wg sync.WaitGroup
	foo := make(chan int)
	bar := make(chan int)
	wg.Add(1)
	go func() {
		defer wg.Done()
		select {
		case foo <- <-bar:
		default:
			println("default")
		}
	}()
	wg.Wait()
}
```

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/kF4pOjYXbXf" target="_blank">Try it</a>
<code class="language-shell">fatal error: all goroutines are asleep - deadlock!
</code></pre></details>
{{< /note >}}



{{< note title="select1" >}}

```go
package main

import "fmt"

func main() {
	ch1 := make(chan int)
	ch2 := make(chan int)
	go func() {
		ch1 <- 1
	}()

	go func() {
		select {
		case <-ch1:
		case ch2 <- 2:
		}
	}()

	fmt.Println(<-ch2)
}
```

- A. 1
- B. 2
- C. No output, program is deadlocked
- D. No output, program has finished execution.
- E. else

<details>
<summary>Answer</summary>
<pre><a href="https://go.dev/play/p/lPURBGXle_N" target="_blank">Try it</a>
<code>B
</code></pre></details>
{{< /note >}}

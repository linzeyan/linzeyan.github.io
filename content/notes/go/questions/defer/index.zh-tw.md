---
title: Defer
weight: 120
menu:
  notes:
    name: Defer
    identifier: notes-go-questions-defer
    parent: notes-go-questions
    weight: 20
---

{{< note title="defer" >}}

```go
package main

import (
    "fmt"
)

func main() {
    defer_call()
}

func defer_call() {
    defer func() { fmt.Println("1") }()
    defer func() { fmt.Println("2") }()
    defer func() { fmt.Println("3") }()

    panic("4")
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">3
2
1
panic: 4
</code></pre></details>
{{< /note >}}



{{< note title="defer1" >}}

```go
package main

import (
	"fmt"
)

type Person struct {
	age int
}

func main() {
	person := &Person{28}

	defer fmt.Println(person.age)

	defer func(p *Person) {
		fmt.Println(p.age)
	}(person)

	defer func() {
		fmt.Println(person.age)
	}()

	person.age = 29
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">29
29
28
</code></pre></details>
{{< /note >}}



{{< note title="defer2" >}}

```go
package main

import (
	"fmt"
)

type Person struct {
	age int
}

func main() {
	person := &Person{28}

	defer fmt.Println(person.age)

	defer func(p *Person) {
		fmt.Println(p.age)
	}(person)

	defer func() {
		fmt.Println(person.age)
	}()

	person = &Person{29}
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">29
28
28
</code></pre></details>
{{< /note >}}



{{< note title="defer3" >}}

```go
package main

import (
	"fmt"
)

var a bool = true

func main() {
	defer func() {
		fmt.Println("1")
	}()
	if a == true {
		fmt.Println("2")
		return
	}
	defer func() {
		fmt.Println("3")
	}()
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">2
1
</code></pre></details>
{{< /note >}}



{{< note title="defer4" >}}

```go
package main

import "fmt"

type temp struct{}

func (t *temp) Add(elem int) *temp {
	fmt.Print(elem)
	return &temp{}
}

func main() {
	tt := &temp{}
	defer tt.Add(1).Add(2)
	tt.Add(3)
}
```

- A. 132
- B. 123
- C. 312
- D. 321

<details>
<summary>Answer</summary>
<pre>
<code>A
</code></pre></details>
{{< /note >}}
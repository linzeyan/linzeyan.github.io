---
title: Interface
weight: 120
menu:
  notes:
    name: Interface
    identifier: notes-go-questions-interface
    parent: notes-go-questions
    weight: 20
---

{{< note title="interface" >}}

```go
package main

import (
	"fmt"
)

type People interface {
	Show()
}

type Student struct{}

func (stu *Student) Show() {

}

func live() People {
	var stu *Student
	return stu
}

func main() {
	if live() == nil {
		fmt.Println("AAAAAAA")
	} else {
		fmt.Println("BBBBBBB")
	}
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">BBBBBBB
</code></pre></details>
{{< /note >}}



{{< note title="interface1" >}}

```go
package main

import (
	"fmt"
)

type People interface {
	Speak(string) string
}

type Student struct{}

func (stu *Student) Speak(think string) (talk string) {
	if think == "love" {
		talk = "You are a good boy"
	} else {
		talk = "hi"
	}
	return
}

func main() {
	var peo People = Student{}
	think := "love"
	fmt.Println(peo.Speak(think))
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">compilation error
cannot use Student{} (value of type Student) as People value in variable declaration: Student does not implement People (method Speak has pointer receiver)
</code></pre></details>
{{< /note >}}

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



{{< note title="interface2" >}}

```go
package main

import "fmt"

type T1 struct {
	String func() string
}

func (T1) Error() string {
	return "T1.Error"
}

type T2 struct {
	Error func() string
}

func (T2) String() string {
	return "T2.String"
}

var t1 = T1{String: func() string { return "T1.String" }}
var t2 = T2{Error: func() string { return "T2.Error" }}

func main() {
	fmt.Println(t1.Error(), t1.String())
	fmt.Println(t2.Error(), t2.String())

	fmt.Println(t1, t2)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">T1.Error T1.String
T2.Error T2.String
T1.Error T2.String
</code></pre></details>
{{< /note >}}



{{< note title="interface3" >}}

```go
package main

import "fmt"

func main() {
	var p [100]int
	var m interface{} = [...]int{99: 0}
	fmt.Println(p == m)
}

```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">true
</code></pre></details>
{{< /note >}}

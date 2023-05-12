---
title: Go Questions
weight: 100
menu:
  notes:
    name: Questions
    identifier: notes-go-questions
    parent: notes-go
    weight: 10
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



{{< note title="context" >}}

```go
package main

import (
	"context"
	"fmt"
)

func f(ctx context.Context) {
	context.WithValue(ctx, "foo", -6)
}

func main() {
	ctx := context.TODO()
	f(ctx)
	fmt.Println(ctx.Value("foo"))
}
```

- A. -6
- B. 0
- C. `<nil>`
- D: panic

<details>
<summary>Answer</summary>
<pre>
<code">C
</code></pre></details>
{{< /note >}}



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



{{< note title="iota" >}}

```go
package main

import "fmt"

const (
	x = iota
	_
	y
	z = "zz"
	k
	p = iota
)

func main() {
	fmt.Println(x, y, z, k, p)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0 2 zz zz 5
</code></pre></details>
{{< /note >}}



{{< note title="iota1" >}}

```go
package main

import "fmt"

const (
	a = iota
	b = iota
)

const (
	name = "name"
	c    = iota
	d    = iota
)

func main() {
	fmt.Println(a, b, c, d)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0 1 1 2
</code></pre></details>
{{< /note >}}



{{< note title="json" >}}

```go
package main

import (
	"encoding/json"
	"fmt"
)

type AutoGenerated struct {
	Age   int    `json:"age"`
	Name  string `json:"name"`
	Child []int  `json:"child"`
}

func main() {
	jsonStr1 := `{"age": 14,"name": "potter", "child":[1,2,3]}`
	a := AutoGenerated{}
	json.Unmarshal([]byte(jsonStr1), &a)
	aa := a.Child
	fmt.Println(aa)
	jsonStr2 := `{"age": 12,"name": "potter", "child":[3,4,5,7,8,9]}`
	json.Unmarshal([]byte(jsonStr2), &a)
	fmt.Println(aa)
}
```
- A. [1 2 3] [1 2 3]
- B. [1 2 3] [3 4 5]
- C. [1 2 3] [3 4 5 6 7 8 9]
- D. [1 2 3] [3 4 5 0 0 0]

<details>
<summary>Answer</summary>
<pre>
<code>B
</code></pre></details>
{{< /note >}}



{{< note title="json1" >}}

```go
package main

import (
	"encoding/json"
	"fmt"
	"time"
)

func main() {
	t := struct {
		time.Time
		N int
	}{
		time.Date(2020, 12, 20, 0, 0, 0, 0, time.UTC),
		5,
	}

	m, _ := json.Marshal(t)
	fmt.Printf("%s", m)
}

```
- A. {"Time":"2020-12-20T00:00:00Z","N":5}
- B. "2020-12-20T00:00:00Z"
- C. {"N":5}
- D. <nil>
- E. 其他

<details>
<summary>Answer</summary>
<pre>
<code>B
</code></pre></details>
{{< /note >}}



{{< note title="len" >}}

```go
package main

func main() {
	var x *struct {
		s [][32]byte
	}

	println(len(x.s[99]))
}
```
- A. panic
- B. compilation error
- C. 32
- D. 0

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="len1" >}}

```go
package main

const s = "Go101.org"

// len(s) == 9
// 1 << 9 == 512
// 512 / 128 == 4

var a byte = 1 << len(s) / 128
var b byte = 1 << len(s[:]) / 128

func main() {
	println(a, b)
}
```
- A: 0 0
- B: 0 4
- C: 4 0
- D: 4 4

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="len2" >}}

```go
package main

var s = "Go101.org"

// len(s) == 9
// 1 << 9 == 512
// 512 / 128 == 4

var a byte = 1 << len(s) / 128
var b byte = 1 << len(s[:]) / 128

func main() {
	println(a, b)
}
```
- A: 0 0
- B: 0 4
- C: 4 0
- D: 4 4

<details>
<summary>Answer</summary>
<pre>
<code>A
</code></pre></details>
{{< /note >}}



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
<pre>
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
<pre>
<code>B
</code></pre></details>
{{< /note >}}



{{< note title="slice" >}}

```go
package main

import (
  "fmt"
)

func main() {
  var s1 []int
  var s2 = []int{}
  if __ == nil {
    fmt.Println("nil slice")
  }
  if __ != nil {
    fmt.Println("empty slice")
  }
}
```
- A. s1, s2
- B. s2, s1
- C. s1, s1
- D. s2, s2

<details>
<summary>Answer</summary>
<pre>
<code>A
</code></pre></details>
{{< /note >}}



{{< note title="slice1" >}}

```go
package main

import (
  "fmt"
)

func main() {
  s := [3]int{1, 2, 3}
  a := s[:0]
  b := s[:2]
  c := s[1:2:cap(s)]
  fmt.Println(len(a), cap(a))
  fmt.Println(len(b), cap(b))
  fmt.Println(len(c), cap(c))
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">0 3
2 3
1 2
</code></pre></details>
{{< /note >}}



{{< note title="slice2" >}}

```go
package main

import "fmt"

func main() {
	s1 := []int{1, 2, 3}
	s2 := s1[1:]
	s2[1] = 4
	fmt.Println(s1)
	s2 = append(s2, 5, 6, 7)
	fmt.Println(s1)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">[1 2 4]
[1 2 4]
</code></pre></details>
{{< /note >}}



{{< note title="variable" >}}

- A. p.name
- B. (&p).name
- C. (*p).name
- D. p->name

<details>
<summary>Answer</summary>
<pre>
<code>AC
</code></pre></details>
{{< /note >}}



{{< note title="variable1" >}}
```go
package main

import (
	"fmt"
)

func main() {
	var ans float64 = 15 + 25 + 5.2
	fmt.Println(ans)
}
```
- A. 45
- B. 45.0
- C. 45.2
- D. compliation error

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="variable2" >}}
```go
package main

import (
	"fmt"
)

func main() {
	var ans float64 = 3 / 2
	fmt.Println(ans)
}
```
- A. 1.5
- B. 1
- C. 0
- D. compliation error

<details>
<summary>Answer</summary>
<pre>
<code>B
</code></pre></details>
{{< /note >}}



{{< note title="variable3" >}}
```go
package main

func main() {
	const a int8 = -1
	var b int8 = -128 / a

	println(b)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">compliation error
-128 / a (constant 128 of type int8) overflows int8
</code></pre></details>
{{< /note >}}



{{< note title="variable4" >}}
```go
package main

func main() {
	var a int8 = -1
	var b int8 = -128 / a

	println(b)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">-128
</code></pre></details>
{{< /note >}}



{{< note title="variable5" >}}

```go
package main

import "fmt"

type MyInt1 int
type MyInt2 = int

func main() {
	var i int =0
	var i1 MyInt1 = i
	var i2 MyInt2 = i
	fmt.Println(i1, i2)
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">compilation error
cannot use i (variable of type int) as MyInt1 value in variable declaration
</code></pre></details>
{{< /note >}}



{{< note title="variable6" >}}

```go
package main

import "fmt"

func main() {
	const X = 7.0
	var x interface{} = X
	if y, ok := x.(int); ok {
		fmt.Println(y)
	} else {
		fmt.Println(int(y))
	}
}
```
- A. 7
- B. 7.0
- C. 0
- D. compilation error

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}

---
title: "Go string format"
date: 2022-09-08T11:32:00+08:00
menu:
  sidebar:
    name: "Go string format"
    identifier: golang-string-format
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [Go string format](https://zetcode.com/golang/string-format/)
- [Go 语言 fmt.Printf 使用指南](https://www.liwenzhou.com/posts/Go/fmt/)

The verb at the end defines the type and the interpretation of its corresponding argument.

- `d` - decimal integer
- `o` - octal integer
- `O` - octal integer with `0o` prefix
- `b` - binary integer
- `x` - hexadecimal integer lowercase
- `X` - hexadecimal integer uppercase
- `f` - decimal floating point, lowercase
- `F` - decimal floating point, uppercase
- `e` - scientific notation (mantissa/exponent), lowercase
- `E` - scientific notation (mantissa/exponent), uppercase
- `g` - the shortest representation of `%e` or `%f`
- `G` - the shortest representation of `%E` or `%F`
- `c` - a character represented by the corresponding Unicode code point
- `q` - a quoted character
- `U` - Unicode escape sequence
- `t` - the word true or false
- `s` - a string
- `v` - default format
- `#v` - Go-syntax representation of the value
- `T` - a Go-syntax representation of the type of the value
- `p` - pointer address
- `%` - a double `%%` prints a single `%`

### Go string format indexing

```go
package main

import (
    "fmt"
)

func main() {

    n1 := 2
    n2 := 3
    n3 := 4

    res := fmt.Sprintf("There are %d oranges %d apples %d plums", n1, n2, n3)
    fmt.Println(res) // There are 2 oranges 3 apples 4 plums

    res2 := fmt.Sprintf("There are %[2]d oranges %d apples %[1]d plums", n1, n2, n3)
    fmt.Println(res2) // There are 3 oranges 4 apples 2 plums
}
```

### Go string format precision

```go
package main

import (
    "fmt"
)

func main() {

    fmt.Printf("%0.f\n", 16.540) // 17
    fmt.Printf("%0.2f\n", 16.540) // 16.54
    fmt.Printf("%0.3f\n", 16.540) // 16.540
    fmt.Printf("%0.5f\n", 16.540) // 16.54000
}

```

### Go string format flags

```go
package main

import (
    "fmt"
)

func main() {

    fmt.Printf("%+d\n", 1691) // +1691

    fmt.Printf("%#x\n", 1691) // 0x69b
    fmt.Printf("%#X\n", 1691) // 0X69B
    fmt.Printf("%#b\n", 1691) // 0b11010011011

    fmt.Printf("%10d\n", 1691)  //       1691
    fmt.Printf("%-10d\n", 1691) // 1691
    fmt.Printf("%010d\n", 1691) // 0000001691
}
```

### Go string format width

```go
package main

import (
    "fmt"
)

func main() {

    w := "falcon"
    n := 122
    h := 455.67

    fmt.Printf("%s\n", w)   // falcon
    fmt.Printf("%10s\n", w) //     falcon

    fmt.Printf("%d\n", n).  // 122
    fmt.Printf("%7d\n", n)  //     122
    fmt.Printf("%07d\n", n) // 0000122

    fmt.Printf("%10f\n", h) // 455.670000
    fmt.Printf("%11f\n", h) //  455.670000
    fmt.Printf("%12f\n", h) //   455.670000
}

```

---
title: "Go 字串格式化"
date: 2022-09-08T11:32:00+08:00
menu:
  sidebar:
    name: "Go 字串格式化"
    identifier: golang-string-format
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go 字串格式化](https://zetcode.com/golang/string-format/)
- [Go 語言 fmt.Printf 使用指南](https://www.liwenzhou.com/posts/Go/fmt/)

結尾的動詞（verb）決定對應參數的型別與解讀方式。

- `d` - 十進位整數
- `o` - 八進位整數
- `O` - 帶有 `0o` 前綴的八進位整數
- `b` - 二進位整數
- `x` - 十六進位整數（小寫）
- `X` - 十六進位整數（大寫）
- `f` - 十進位浮點數（小寫）
- `F` - 十進位浮點數（大寫）
- `e` - 科學記號（尾數/指數，小寫）
- `E` - 科學記號（尾數/指數，大寫）
- `g` - `%e` 或 `%f` 的最短表示
- `G` - `%E` 或 `%F` 的最短表示
- `c` - 以 Unicode 碼點表示的字元
- `q` - 帶引號的字元
- `U` - Unicode 逸出序列
- `t` - true 或 false 字串
- `s` - 字串
- `v` - 預設格式
- `#v` - 值的 Go 語法表示
- `T` - 值型別的 Go 語法表示
- `p` - 指標位址
- `%` - 雙 `%%` 會輸出單一 `%`

### Go 字串格式化索引

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

### Go 字串格式化精度

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

### Go 字串格式化旗標

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

### Go 字串格式化寬度

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

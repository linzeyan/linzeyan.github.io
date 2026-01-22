---
title: "Go Generics 入門筆記"
date: 2024-02-07T19:52:22+08:00
menu:
  sidebar:
    name: "Go Generics 入門筆記"
    identifier: go-generic-beginner-notes
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go Generics 入門筆記](https://ganhua.wang/go-generic)

#### 自訂約束

```go
// Addable 只允許 int 或 float64 類型
type Addable interface {
    int | float64
}

func Add[T Addable](a, b T) T {
    return a + b
}
```

**_`~` 符號的作用_**
`~` 符號用於表示與指定類型有相同底層類型的所有類型。當你在類型參數的約束中使用 `~` 符號時，你指定了一個類型集合，這個集合包含所有底層類型與約束中指定的類型相同的類型。

```go
type MyInt int
type YourInt int

func PrintInt[T ~int](t T) {
    fmt.Println(t)
}

func main() {
    var a int = 5
    var b MyInt = 10
    var c YourInt = 15

    PrintInt(a)
    PrintInt(b)
    PrintInt(c)
}
```

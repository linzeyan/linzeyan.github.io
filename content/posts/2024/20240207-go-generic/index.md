---
title: "Go Generics Beginner Notes"
date: 2024-02-07T19:52:22+08:00
menu:
  sidebar:
    name: "Go Generics Beginner Notes"
    identifier: go-generic-beginner-notes
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go Generics Beginner Notes](https://ganhua.wang/go-generic)

#### Custom Constraints

```go
// Addable allows only int or float64 types
type Addable interface {
    int | float64
}

func Add[T Addable](a, b T) T {
    return a + b
}
```

**_What `~` Means_**
`~` represents all types that share the same underlying type as the specified type. When you use `~` in a type parameter constraint, you define a type set that includes all types whose underlying type matches the specified type.

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

---
title: "Go embed 简明教程"
date: 2022-07-12T13:57:03+08:00
menu:
  sidebar:
    name: "Go embed 简明教程"
    identifier: golang-go-embed-tutorial
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [Go embed 简明教程](https://colobu.com/2021/01/17/go-embed-tutorial/)

### 嵌入

- 对于单个的文件，支持嵌入为`string`和 `[]byre`
- 对于多个文件和文件夹，支持嵌入为新的文件系统 FS
- 比如导入 "embed" 包，即使无显式的使用
- `go:embed` 指令用来嵌入，必须紧跟着嵌入后的变量名
- 只支持嵌入为 `string`, `[]byte` 和 `embed.FS` 三种类型，这三种类型的别名(alias)和命名类型(如 type S string)都不可以
- 使用的是相对路径

#### string/[]byte

```go
package main

import (
	_ "embed"
	"fmt"
)

//go:embed hello.txt
var s string

//go:embed hello.txt
var b []byte

func main() {
	fmt.Println(s)
	fmt.Println(b)
}
```

#### embed.FS

```go
package main

import (
	"embed"
	"fmt"
)

//go:embed hello.txt hello2.txt
//go:embed "p/he llo.txt"
//go:embed `p/hello-2.txt`
//go:embed dir
var f embed.FS
func main() {
	data, _ := f.ReadFile("hello.txt")
	fmt.Println(string(data))
	data, _ = f.ReadFile("hello2.txt")
    fmt.Println(string(data))
	data, _ := f.ReadFile("p/he llo.txt")
	fmt.Println(string(data))
	data, _ = f.ReadFile("p/hello-2.txt")
	fmt.Println(string(data))
}
```

##### 匹配模式

go:embed 指令中可以只写文件夹名，此文件夹中除了.和\_开头的文件和文件夹都会被嵌入，并且子文件夹也会被递归的嵌入，形成一个此文件夹的文件系统。

如果想嵌入.和\_开头的文件和文件夹， 比如 p 文件夹下的.hello.txt 文件，那么就需要使用*，比如 go:embed p/*。

*不具有递归性，所以子文件夹下的.和\_不会被嵌入，除非你在专门使用子文件夹的*进行嵌入

```go
package main
import (
	"embed"
	"fmt"
)

//go:embed p/*
var f embed.FS

//go:embed *
var ff embed.FS

func main() {
	data, _ := f.ReadFile("p/.hello.txt")
	fmt.Println(string(data))
	data, _ = f.ReadFile("p/q/.hi.txt") // 没有嵌入 p/q/.hi.txt
	fmt.Println(string(data))

	data, _ := ff.ReadFile("hello.txt")
	fmt.Println(string(data))
	data, _ = ff.ReadFile(".hello.txt")
	fmt.Println(string(data))
}
```

#### net/http

`http.Handle("/", http.FileServer(http.FS(ff)))`

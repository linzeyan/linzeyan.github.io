---
title: "A Concise Go embed Tutorial"
date: 2022-07-12T13:57:03+08:00
menu:
  sidebar:
    name: "A Concise Go embed Tutorial"
    identifier: golang-go-embed-tutorial
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [A Concise Go embed Tutorial](https://colobu.com/2021/01/17/go-embed-tutorial/)

### Embedding

- For a single file, you can embed it as `string` or `[]byte`
- For multiple files and directories, you can embed them as a new filesystem (FS)
- Import the "embed" package even if it is not explicitly used
- The `go:embed` directive is used for embedding and must be followed by the target variable name
- Only `string`, `[]byte`, and `embed.FS` are supported. Aliases and named types (e.g., type S string) are not allowed
- Uses relative paths

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

##### Matching patterns

go:embed can take just a directory name. All files and directories inside, except those starting with . and _, are embedded. Subdirectories are embedded recursively to form a filesystem for that directory.

If you want to embed files and directories starting with . and _, such as p/.hello.txt, you need to use *, e.g., go:embed p/*.

The * pattern is not recursive, so . and _ files in subdirectories are not embedded unless you use a * specifically for the subdirectory.

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
	data, _ = f.ReadFile("p/q/.hi.txt") // p/q/.hi.txt is not embedded
	fmt.Println(string(data))

	data, _ := ff.ReadFile("hello.txt")
	fmt.Println(string(data))
	data, _ = ff.ReadFile(".hello.txt")
	fmt.Println(string(data))
}
```

#### net/http

`http.Handle("/", http.FileServer(http.FS(ff)))`

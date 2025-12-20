---
title: "[Golang] 利用build tags達到不同的build config"
date: 2022-07-18T14:21:34+08:00
menu:
  sidebar:
    name: "[Golang] 利用build tags達到不同的build config"
    identifier: golang-go-build-config-ldflags
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [[Golang] 利用 build tags 達到不同的 build config](https://www.evanlin.com/go-build-config-ldflags/)

##### Go build -ldflags

```go
package main

import (
	"fmt"
)

var flagString string

func main() {
	fmt.Println("This build with ldflag:", flagString)
}
```

```bash
$ go build -ldflags '-X main.flagString "test"'

$ ./main
This build with ldflag: test
```

##### Go build -tags

###### debug_config.go

```go
//+build debug

package main

var TestString string = "test debug"
var TestString2 string = " and it will run every module with debug tag."

func GetConfigString() string {
	return "it is debug....."
}
```

{{< alert type="warning" >}}
`//+build debug` 前後需要一個空行(除非你在第一行)
{{< /alert >}}

###### release_config.go

```go
//+build !debug

package main

var TestString string = "test release"
var TestString2 string = " and it will run every module as no debug tag."

func GetConfigString() string {
	return "it is release....."
}
```

###### main

```go
package main

import (
	"fmt"
)

func main() {
	fmt.Println("This build is ", TestString, TestString2, GetConfigString())
}
```

---

```shell
$ go build -tags debug .
$ ./main
This build is  test debug  and it will run every module with debug tag. it is debug.....

$ go build .
$ ./main
This build is  test release  and it will run every module as no debug tag. it is release.....
```

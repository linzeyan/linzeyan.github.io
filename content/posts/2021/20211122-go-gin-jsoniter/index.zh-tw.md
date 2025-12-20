---
title: "Gin 框架绑定 JSON 参数使用 jsoniter"
date: 2021-11-22T10:27:39+08:00
menu:
  sidebar:
    name: "Gin 框架绑定 JSON 参数使用 jsoniter"
    identifier: go-gin-jsoniter
    weight: 10
tags: ["URL", "Go", "GIN", "jsoniter"]
categories: ["URL", "Go", "GIN", "jsoniter"]
hero: images/hero/go.svg
---

- [Gin 框架绑定 JSON 参数使用 jsoniter](https://mp.weixin.qq.com/s/nf9OYpN3f8HMDj_xkdCzdw)

### simple

```bash
go build -tags=jsoniter ./...
```

### custom

#### implement `BindingBody` interface

```go
// github.com/gin-gonic/gin@v1.6.3/binding/binding.go:36
// Binding describes the interface which needs to be implemented for binding the
// data present in the request such as JSON request body, query parameters or
// the form POST.
type Binding interface {
    Name() string
    Bind(*http.Request, interface{}) error
}
// BindingBody adds BindBody method to Binding. BindBody is similar with Bind,
// but it reads the body from supplied bytes instead of req.Body.
type BindingBody interface {
    Binding
    BindBody([]byte, interface{}) error
}
```

```go
package custom
import (
    "bytes"
    "fmt"
    "io"
    "net/http"
    jsoniter "github.com/json-iterator/go"
    "github.com/gin-gonic/gin/binding"
)
// BindingJSON 替换Gin默认的binding，支持更丰富JSON功能
var BindingJSON = jsonBinding{}
// 可以自定义jsoniter配置或者添加插件
var json = jsoniter.ConfigCompatibleWithStandardLibrary
type jsonBinding struct{}
func (jsonBinding) Name() string {
    return "json"
}
func (jsonBinding) Bind(req *http.Request, obj interface{}) error {
    if req == nil || req.Body == nil {
        return fmt.Errorf("invalid request")
    }
    return decodeJSON(req.Body, obj)
}
func (jsonBinding) BindBody(body []byte, obj interface{}) error {
    return decodeJSON(bytes.NewReader(body), obj)
}
func decodeJSON(r io.Reader, obj interface{}) error {
    decoder := json.NewDecoder(r)
    if binding.EnableDecoderUseNumber {
        decoder.UseNumber()
    }
    if binding.EnableDecoderDisallowUnknownFields {
        decoder.DisallowUnknownFields()
    }
    if err := decoder.Decode(obj); err != nil {
        return err
    }
    return validate(obj)
}
func validate(obj interface{}) error {
    if binding.Validator == nil {
        return nil
    }
    return binding.Validator.ValidateStruct(obj)
}
```

```go
// binding.JSON 替换成自定义的
ctx.ShouldBindWith(ms, binding.JSON)
ctx.ShouldBindBodyWith(ms, binding.JSON)
```

---
title: Go Snippet
weight: 100
menu:
  notes:
    name: Snippet
    identifier: notes-go-snippet
    parent: notes-go
    weight: 10
---

{{< note title="ETCD TTL" >}}

```go
func main() {
	// 创建 etcd 客户端
	cli, err := clientv3.New(clientv3.Config{
		Endpoints:   []string{"localhost:2379"},
		DialTimeout: 5 * time.Second,
	})
	if err != nil {
		fmt.Println("Error connecting to etcd:", err)
		return
	}
	defer cli.Close()

	// 设置 TTL (单位为秒)
	ttl := int64(10) // 例如 10 秒
	resp, err := cli.Grant(context.TODO(), ttl)
	if err != nil {
		fmt.Println("Error creating lease:", err)
		return
	}

	// 使用 Lease ID 进行 Put 操作
	_, err = cli.Put(context.TODO(), "my-key", "my-value", clientv3.WithLease(resp.ID))
	if err != nil {
		fmt.Println("Error putting key with lease:", err)
		return
	}

	fmt.Println("Key with TTL successfully set.")
}
```

{{< /note >}}

{{< note title="gRPC UnaryInterceptor" >}}

```go
func unaryInterceptor(
  ctx context.Context,
  req any,
  info *googleGrpc.UnaryServerInfo,
  handler googleGrpc.UnaryHandler,
) (any, error) {
  // 打印被调用的方法名
  fmt.Println("Called method:", info.FullMethod)

  // 打印传入的请求参数
  fmt.Printf("Request: %+v\n", req)

  fmt.Printf("Meta: %+v\n", util.GetReqInfoFromCtx(ctx))
  // 调用实际的 handler
  response, err := handler(ctx, req)
  if err != nil {
    fmt.Println("err: ", err)
  }
  return response, err
}
```

{{< /note >}}

{{< note title="isRunningTest" >}}

```go
// isRunningTest 確認是否在跑測試
func isRunningTest() bool {
  return flag.Lookup("test.v") != nil
}
```

{{< /note >}}

{{< note title="GIN dto validator" >}}

```go
package validator

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"reflect"
	"sync"

	"github.com/gin-gonic/gin"
	"github.com/gin-gonic/gin/binding"
)

const (
	MB      = 1 << 20
	maxBody = 5 * MB
)

var srcCache sync.Map // reflect.Type -> srcInfo
type srcInfo struct{ form, uri, validate bool }

type Binder interface {
	Validate(*gin.Context) error
}

func infoOf(t reflect.Type) srcInfo {
	if v, ok := srcCache.Load(t); ok {
		return v.(srcInfo)
	}

	var s srcInfo
	seen := map[reflect.Type]bool{} // 在遞迴外層，所有層級共用

	var scan func(reflect.Type)
	scan = func(t reflect.Type) {
		for isWrapper(t.Kind()) {
			t = t.Elem()
		}
		if t.Kind() != reflect.Struct || seen[t] {
			return
		}
		seen[t] = true
		for f := range t.Fields() {
			if _, ok := f.Tag.Lookup("form"); ok {
				s.form = true
			}
			if _, ok := f.Tag.Lookup("uri"); ok {
				s.uri = true
			}
			if _, ok := f.Tag.Lookup("binding"); ok {
				s.validate = true
			}
			scan(f.Type)
		}
	}
	scan(t)

	srcCache.Store(t, s)
	return s
}

func isWrapper(k reflect.Kind) bool {
	switch k {
	case reflect.Pointer, reflect.Slice, reflect.Array, reflect.Map:
		return true
	}
	return false
}

func Bind[T any](c *gin.Context) (*T, error) {
	req := new(T)
	// 有 body 才解 JSON
	if c.Request.ContentLength != 0 && c.ContentType() == binding.MIMEJSON {
		body := http.MaxBytesReader(c.Writer, c.Request.Body, maxBody)
		if err := json.NewDecoder(body).Decode(req); err != nil && !errors.Is(err, io.EOF) {
			return nil, err
		}
	}
	info := infoOf(reflect.TypeFor[T]())
	// 有 query 才映射
	if info.form && c.Request.URL.RawQuery != "" {
		if err := binding.MapFormWithTag(req, c.Request.URL.Query(), "form"); err != nil {
			return nil, err
		}
	}
	// 有 path 參數才映射
	if info.uri && len(c.Params) > 0 {
		m := make(map[string][]string, len(c.Params))
		for _, p := range c.Params {
			m[p.Key] = []string{p.Value}
		}
		if err := binding.MapFormWithTag(req, m, "uri"); err != nil {
			return nil, err
		}
	}
	// 有 binding tag 才驗證
	if info.validate {
		if err := binding.Validator.ValidateStruct(req); err != nil {
			return nil, err
		}
	}
	// 有實作才呼叫
	if v, ok := any(req).(Binder); ok {
		if err := v.Validate(c); err != nil {
			return nil, err
		}
	}
	return req, nil
}

func MustBind[T any](c *gin.Context) (*T, bool) {
	req, err := Bind[T](c)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return nil, false
	}
	return req, true
}

```

{{< /note >}}

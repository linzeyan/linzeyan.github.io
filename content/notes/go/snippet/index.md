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
  req interface{},
  info *googleGrpc.UnaryServerInfo,
  handler googleGrpc.UnaryHandler,
) (interface{}, error) {
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

---
title: "更强大的Go执行跟踪能力"
date: 2024-05-07T11:45:57+08:00
menu:
  sidebar:
    name: "更强大的Go执行跟踪能力"
    identifier: go-trace
    weight: 10
tags: ["URL", "Go", "trace"]
categories: ["URL", "Go", "trace"]
hero: images/hero/go.svg
---

- [更强大的 Go 执行跟踪能力](https://colobu.com/2024/03/18/execution-traces-2024/)

### runtime/trace

### golang.org/x/exp/trace

#### 飞行记录(flight recording)

```go
// 设置飞行记录器
fr := trace.NewFlightRecorder()
fr.Start()
// 设置和运行HTTP服务器
var once sync.Once
http.HandleFunc("/my-endpoint", func(w http.ResponseWriter, r *http.Request) {
    start := time.Now()
    // 干些事情
    doWork(w, r)
    // 盼到了长耗时请求，来个快照
    if time.Since(start) > 300*time.Millisecond {
        // 这里我们为了简化只做一次，实际上你可以做多次
        once.Do(func() {
            // 抓取快照
            var b bytes.Buffer
            _, err = fr.WriteTo(&b)
            if err != nil {
                log.Print(err)
                return
            }
            // 把快照写入文件
            if err := os.WriteFile("trace.out", b.Bytes(), 0o755); err != nil {
                log.Print(err)
                return
            }
        })
    }
})
log.Fatal(http.ListenAndServe(":8080", nil))
```

#### 跟踪读取器 API

```go
// 开始从标准输入读取跟踪数据。
r, err := trace.NewReader(os.Stdin)
if err != nil {
    log.Fatal(err)
}
var blocked int
var blockedOnNetwork int
for {
    // 读取事件
    ev, err := r.ReadEvent()
    if err == io.EOF {
        break
    } else if err != nil {
        log.Fatal(err)
    }
    // 处理它
    if ev.Kind() == trace.EventStateTransition {
        st := ev.StateTransition()
        if st.Resource.Kind == trace.ResourceGoroutine {
            id := st.Resource.Goroutine()
            from, to := st.GoroutineTransition()
            // 查找阻塞的goroutine, 统计计数
            if from.Executing() && to == trace.GoWaiting {
                blocked++
                if strings.Contains(st.Reason, "network") {
                    blockedOnNetwork++
                }
            }
        }
    }
}

// 打印我们所需
p := 100 * float64(blockedOnNetwork) / float64(blocked)
fmt.Printf("%2.3f%% instances of goroutines blocking were to block on the network\n", p)
```

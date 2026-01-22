---
title: "更強大的 Go 執行追蹤能力"
date: 2024-05-07T11:45:57+08:00
menu:
  sidebar:
    name: "更強大的 Go 執行追蹤能力"
    identifier: go-trace
    weight: 10
tags: ["Links", "Go", "trace"]
categories: ["Links", "Go", "trace"]
hero: images/hero/go.svg
---

- [更強大的 Go 執行追蹤能力](https://colobu.com/2024/03/18/execution-traces-2024/)

### runtime/trace

### golang.org/x/exp/trace

#### 飛行記錄（flight recording）

```go
// 設定飛行記錄器
fr := trace.NewFlightRecorder()
fr.Start()
// 設定並啟動 HTTP 伺服器
var once sync.Once
http.HandleFunc("/my-endpoint", func(w http.ResponseWriter, r *http.Request) {
    start := time.Now()
    // 做些事情
    doWork(w, r)
    // 碰到長耗時請求就來個快照
    if time.Since(start) > 300*time.Millisecond {
        // 這裡為了簡化只做一次，實際上你可以做多次
        once.Do(func() {
            // 擷取快照
            var b bytes.Buffer
            _, err = fr.WriteTo(&b)
            if err != nil {
                log.Print(err)
                return
            }
            // 把快照寫入檔案
            if err := os.WriteFile("trace.out", b.Bytes(), 0o755); err != nil {
                log.Print(err)
                return
            }
        })
    }
})
log.Fatal(http.ListenAndServe(":8080", nil))
```

#### 追蹤讀取器 API

```go
// 開始從標準輸入讀取追蹤資料。
r, err := trace.NewReader(os.Stdin)
if err != nil {
    log.Fatal(err)
}
var blocked int
var blockedOnNetwork int
for {
    // 讀取事件
    ev, err := r.ReadEvent()
    if err == io.EOF {
        break
    } else if err != nil {
        log.Fatal(err)
    }
    // 處理它
    if ev.Kind() == trace.EventStateTransition {
        st := ev.StateTransition()
        if st.Resource.Kind == trace.ResourceGoroutine {
            id := st.Resource.Goroutine()
            from, to := st.GoroutineTransition()
            // 查找阻塞的 goroutine 並統計
            if from.Executing() && to == trace.GoWaiting {
                blocked++
                if strings.Contains(st.Reason, "network") {
                    blockedOnNetwork++
                }
            }
        }
    }
}

// 印出所需數值
p := 100 * float64(blockedOnNetwork) / float64(blocked)
fmt.Printf("%2.3f%% instances of goroutines blocking were to block on the network\n", p)
```

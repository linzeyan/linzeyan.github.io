---
title: "Go Tool Trace"
date: 2026-01-27T09:54:42+08:00
menu:
  sidebar:
    name: "Go Tool Trace"
    identifier: golang-profiling-go-tool-trace-introduction-by-ray
    weight: 10
tags: ["Links", "Go", "trace"]
categories: ["Links", "Go", "trace"]
hero: images/hero/go.svg
---

- [淺談 Go Tool Trace - 1](https://ithelp.ithome.com.tw/articles/10350656)
- [淺談 Go Tool Trace - 2 Go Trace 與使用者自訂追蹤分析](https://ithelp.ithome.com.tw/articles/10351336)
- [淺談 Go Tool Trace - 3 實際分析 Goroutine Analysis](https://ithelp.ithome.com.tw/articles/10352139)
- [Go Tool Trace - 4 從 分析到實戰：最佳化 Goroutine 數量](https://ithelp.ithome.com.tw/articles/10352141)
- [trace](https://pkg.go.dev/cmd/trace@go1.23.0)

**_trace 是「事件時間軸」，不是「取樣統計」_**

- `go tool trace`：用來看 **runtime trace（執行追蹤）**，本質是「時間序列事件」：
  - goroutine 的建立 / runnable / running / waiting / syscall
  - scheduler（G/M/P）相關事件、排程延遲
  - blocking（net / sync / syscall）時間分佈
  - GC 事件、STW、heap 變化（在 trace viewer 會看到）
- 用 `pprof` 是找「熱點」：誰吃 CPU / 誰 alloc 多
- 用 `trace` 是找「延遲原因」：**為什麼卡**（排程？鎖？網路？syscall？GC？）

> 直覺判斷：
>
> - 「CPU 明明沒滿卻很慢」→ 先 trace（通常是 blocking / sched）
> - 「CPU 滿到爆、想知道哪個 function 最熱」→ 先 pprof(cpu)

## 1. 跑 trace 的標準流程（以後照抄這條）

### 1.1 先產生 `trace.out`

用 `runtime/trace` 包住「想觀察的 workload」。

### 1.2 開 viewer 看時間軸

```bash
go tool trace trace.out
```

> 小技巧：先找「最慢的那段時間範圍」，再縮放，避免一開始被大量事件淹沒。

### 1.3 需要更明確歸因時，匯出 trace 內建的 blocking profiles（會產生 `.prof`）

```bash
go tool trace -pprof=sched   trace.out > sched.prof
go tool trace -pprof=net     trace.out > net.prof
go tool trace -pprof=sync    trace.out > sync.prof
go tool trace -pprof=syscall trace.out > syscall.prof
```

### 1.4 用 `pprof` 看 `.prof`（要看 top / call graph / list）

```bash
go tool pprof sched.prof
(pprof) top
(pprof) web
(pprof) list main.worker
```

也可以直接開 HTTP UI

```bash
go tool pprof -http :0 sched.prof
```

## 2. trace viewer 裡在看什麼

### 2.1 先看「是不是排程問題」：`sched`（Scheduler latency / runnable 等太久）

- 現象：很多 goroutine 看起來都在等、CPU 卻不高或 latency 很抖
- 先：
  1. 匯出 `sched.prof` → `pprof top`
  2. trace viewer 看 runnable → running 的延遲是否很長
- 常見原因：
  - goroutine 數量爆炸（過度 fan-out）
  - `GOMAXPROCS` / P 的壓力（但多數時候是把 goroutine 開太多）
  - worker pool 沒控好（一次把工作全丟給 goroutine 海）

### 2.2 看「到底卡在哪種 blocking」：`net / sync / syscall`

- `net`：卡在網路 I/O（HTTP / DB / RPC / DNS/timeout）
- `sync`：卡在鎖 / WaitGroup / Cond / channel 協調（lock contention）
- `syscall`：卡在 OS syscall（檔案 I/O、DNS、其他 blocking call）

> 1. 先 `sched`（排程延遲）
> 2. 再 `net/sync/syscall` 找阻塞主因
> 3. 最後再回時間軸驗證「修改後事件型態有沒有變」

## 3. 讓 trace 變好讀的關鍵：加上自訂 Task / Region

> 如果不加 task/region，trace 很容易只剩 runtime 事件：
> 知道它「慢」，但不容易對應到「業務步驟」。

### 3.1 Task：把「一次工作」串成一條（例如一個任務 / 一個 request）

- `trace.NewTask(ctx, "name")` → 產生一個 task 節點，可在 viewer 搜尋/聚合

### 3.2 Region：標記「這一步」做什麼（例如 WriteFile / HTTPGet / CPUWork）

- `trace.WithRegion(ctx, "step", func(){ ... })`
- 把容易卡的步驟切成 region（I/O、鎖、RPC、序列化、計算）

## 4. 用 trace 做優化驗證的策略

### 4.1 先用 Goroutine Analysis 找「最大宗/最耗時」

1. 是「goroutine 數量太多」？（排程壓力、sched latency）
2. 還是「少數 goroutine 很慢」？（net/sync/syscall/GC）

### 4.2 如果是 allocation/GC 壓力：用 `sync.Pool` 做 object reuse

- 只在「大量短生命週期大 buffer」時用 pool（例如重複 `make([]byte, 2MB)`）
- 用 trace 觀察：
  - GC 事件是否變少、卡頓是否降低
  - elapsed 是否下降
  - 記憶體是否變得不可接受（pool 可能增加 RSS）

### 4.3 如果是 sched 壓力：調整 goroutine/worker 數（D18）

**goroutine/worker 的合理數量，跟等待/阻塞佔比有關**

1. baseline：`-workers 1000`（故意設大）跑一次
2. trace 看 `sched` 是否爆炸
3. 把 workers 調小到「CPU 吃得滿且 runnable 延遲下降」的範圍
4. 每次修改都回 trace 驗證（不是只看 elapsed）

## 5. 範例（含 trace + task/region + pool + worker）

### 5.1 `main.go`

```go
package main

import (
	"context"
	"crypto/sha256"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"runtime/pprof"
	"runtime/trace"
	"sync"
	"time"
)

type Options struct {
	Workers     int
	Tasks       int
	TracePath   string
	CPUProfPath string

	UsePool     bool
	PayloadMB   int
	HTTPURL     string
	FileDir     string
	EnableTrace bool
	EnableCPU   bool
}

var bytePool sync.Pool

func initPool(payloadBytes int) {
	bytePool = sync.Pool{
		New: func() any {
			b := make([]byte, payloadBytes)
			// 填一點資料避免完全是零（方便模擬 CPU/IO）
			for i := 0; i < len(b); i += 4096 {
				b[i] = byte(i % 251)
			}
			return b
		},
	}
}

func worker(ctx context.Context, id int, tasks <-chan int, wg *sync.WaitGroup, opt Options, payloadBytes int) {
	defer wg.Done()

	client := &http.Client{Timeout: 3 * time.Second}

	for taskID := range tasks {
		// 每個任務一個 task，讓 trace viewer 能用名稱聚合/搜尋
		taskCtx, taskSpan := trace.NewTask(ctx, fmt.Sprintf("worker=%d task=%d", id, taskID))

		// 取得 payload（可選 sync.Pool）
		var payload []byte
		if opt.UsePool {
			payload = bytePool.Get().([]byte)
		} else {
			payload = make([]byte, payloadBytes)
			for i := 0; i < len(payload); i += 4096 {
				payload[i] = byte((i + taskID) % 251)
			}
		}

		// --- Region: WriteFile ---
		filename := filepath.Join(opt.FileDir, fmt.Sprintf("trace_demo_%d_%d.bin", id, taskID))
		trace.WithRegion(taskCtx, "WriteFile", func() {
			if err := os.WriteFile(filename, payload, 0o644); err != nil {
				log.Printf("[worker=%d task=%d] writefile error: %v", id, taskID, err)
			}
		})

		// --- Region: ReadFile ---
		trace.WithRegion(taskCtx, "ReadFile", func() {
			b, err := os.ReadFile(filename)
			if err != nil {
				log.Printf("[worker=%d task=%d] readfile error: %v", id, taskID, err)
				return
			}
			// 做一點 CPU work（hash）
			_ = sha256.Sum256(b)
		})

		// --- Region: HTTPGet ---
		trace.WithRegion(taskCtx, "HTTPGet", func() {
			req, err := http.NewRequestWithContext(taskCtx, http.MethodGet, opt.HTTPURL, nil)
			if err != nil {
				log.Printf("[worker=%d task=%d] new request error: %v", id, taskID, err)
				return
			}
			resp, err := client.Do(req)
			if err != nil {
				log.Printf("[worker=%d task=%d] http error: %v", id, taskID, err)
				return
			}
			defer resp.Body.Close()
			// 讀少量 body，避免把網路變成唯一瓶頸
			_, _ = io.CopyN(io.Discard, resp.Body, 32*1024)
		})

		// --- cleanup ---
		_ = os.Remove(filename)

		if opt.UsePool {
			bytePool.Put(payload)
		}

		taskSpan.End()
	}
}

func main() {
	var opt Options

	flag.IntVar(&opt.Workers, "workers", 1000, "number of worker goroutines")
	flag.IntVar(&opt.Tasks, "tasks", 2000, "number of tasks")
	flag.StringVar(&opt.TracePath, "trace", "trace.out", "trace output path")
	flag.StringVar(&opt.CPUProfPath, "cpuprofile", "cpu.prof", "cpu profile output path")
	flag.BoolVar(&opt.UsePool, "use-pool", false, "reuse []byte using sync.Pool")
	flag.IntVar(&opt.PayloadMB, "payload-mb", 2, "payload size per task in MB")
	flag.StringVar(&opt.HTTPURL, "url", "https://ithelp.ithome.com.tw/", "http url to fetch (demo)")
	flag.StringVar(&opt.FileDir, "filedir", os.TempDir(), "directory for temp files")
	flag.BoolVar(&opt.EnableTrace, "enable-trace", true, "enable runtime trace")
	flag.BoolVar(&opt.EnableCPU, "enable-cpu", false, "enable CPU profiling")
	flag.Parse()

	payloadBytes := opt.PayloadMB * 1024 * 1024
	if opt.UsePool {
		initPool(payloadBytes)
	}

	// trace/cpu profiling 的啟停我會包住「想觀察的 workload」
	var traceFile *os.File
	if opt.EnableTrace {
		f, err := os.Create(opt.TracePath)
		if err != nil {
			log.Fatalf("create trace file failed: %v", err)
		}
		traceFile = f
		if err := trace.Start(traceFile); err != nil {
			log.Fatalf("trace start failed: %v", err)
		}
		defer func() {
			trace.Stop()
			_ = traceFile.Close()
		}()
	}

	var cpuFile *os.File
	if opt.EnableCPU {
		f, err := os.Create(opt.CPUProfPath)
		if err != nil {
			log.Fatalf("create cpu profile failed: %v", err)
		}
		cpuFile = f
		if err := pprof.StartCPUProfile(cpuFile); err != nil {
			log.Fatalf("cpu profile start failed: %v", err)
		}
		defer func() {
			pprof.StopCPUProfile()
			_ = cpuFile.Close()
		}()
	}

	ctx := context.Background()
	ctx, mainTask := trace.NewTask(ctx, "Main")
	start := time.Now()

	tasks := make(chan int, opt.Tasks)
	var wg sync.WaitGroup

	for i := 0; i < opt.Workers; i++ {
		wg.Add(1)
		go worker(ctx, i, tasks, &wg, opt, payloadBytes)
	}

	for i := 0; i < opt.Tasks; i++ {
		tasks <- i
	}
	close(tasks)

	wg.Wait()

	elapsed := time.Since(start)
	mainTask.End()

	fmt.Printf("Workers: %d, Tasks: %d, UsePool: %v, Elapsed Time: %s
",
		opt.Workers, opt.Tasks, opt.UsePool, elapsed)
}
```

## 6. 指令清單

### 6.1 產生 trace（baseline：故意把 workers 設大）

```bash
go run main.go -workers 1000 -tasks 2000 -enable-trace=true -trace trace.out
```

### 6.2 開 trace viewer

```bash
go tool trace trace.out
```

### 6.3 匯出 blocking profiles（從 trace 轉成 pprof）

```bash
go tool trace -pprof=sched   trace.out > sched.prof
go tool trace -pprof=net     trace.out > net.prof
go tool trace -pprof=sync    trace.out > sync.prof
go tool trace -pprof=syscall trace.out > syscall.prof
```

### 6.4 用 pprof 看（互動模式）

```bash
go tool pprof sched.prof
(pprof) top
(pprof) web
(pprof) list main.worker
```

或直接開 UI：

```bash
go tool pprof -http :0 sched.prof
go tool pprof -http :0 net.prof
go tool pprof -http :0 sync.prof
go tool pprof -http :0 syscall.prof
```

### 6.5 做 worker 數量實驗（把結果記到同一張表）

```bash
# 大（容易把 sched 問題放大）
go run main.go -workers 1000 -tasks 2000 -trace trace_1000.out

# 中
go run main.go -workers 31 -tasks 2000 -trace trace_31.out

# 再調小/微調
go run main.go -workers 25 -tasks 2000 -trace trace_25.out
```

### 6.6 打開 CPU profile（如果要對照 pprof(cpu) 的熱點）

```bash
go run main.go -workers 31 -tasks 2000 -enable-cpu=true -cpuprofile cpu.prof -trace trace.out
go tool pprof -http :0 cpu.prof
```

## 7. trace 結論

### 7.1 先判斷：慢主要是哪一類？

- **sched** 高：runnable 等很久 → 先減 goroutine/worker、做 backpressure
- **sync** 高：鎖/同步卡住 → 找 contention 熱點（縮短 critical section、拆鎖、減共享）
- **net** 高：網路卡住 → 看 downstream latency、timeout、連線池、DNS
- **syscall** 高：OS I/O 卡住 → 看檔案 I/O、磁碟、DNS、其他 blocking syscall
- **GC 明顯**：看 allocation 模式、短命大物件、是否可用 pool 或減少分配

### 7.2 做「前後對照」

- 改 worker 數 / 加 pool / 改同步方式後，同時看：
  1. elapsed time
  2. `sched/net/sync/syscall` profile 的占比是否移動
  3. trace 時間軸上，卡住的事件型態是否改變（有時只是瓶頸轉移）

## 8. 怎麼決定要不要用 Object Pool

1. 真的有大量重複分配（尤其大 buffer），且生命周期短
2. trace/GC 指標顯示 GC 壓力或 alloc 成本是瓶頸之一
3. 願意接受：pool 可能提高峰值記憶體（換速度）

在範例裡：

```bash
go run main.go -workers 31 -tasks 2000 -use-pool=true -trace trace_pool.out
```

然後用同樣方式匯出 profiles 對比：

```bash
go tool trace -pprof=sched trace_pool.out > sched_pool.prof
go tool pprof -http :0 sched_pool.prof
```

## 9. goroutine/worker 數量：把它當「用 trace 驗證的調參」

> worker 不是越多越好；當 runnable 等待（sched latency）變大時，要把 worker 拉回合理區間。

- 用 `-workers 1000` 放大問題 → trace 看 `sched` 是否爆
- 逐步下降 workers（例如 200 → 100 → 50 → 31 → 25）
- 找到「elapsed 改善 + sched latency 明顯下降」的區間
- 再針對 `net/sync/syscall` 做第二輪優化（避免只是在轉移瓶頸）

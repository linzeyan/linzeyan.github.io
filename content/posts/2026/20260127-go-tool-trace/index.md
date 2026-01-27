---
title: "Go Tool Trace"
date: 2026-01-27T09:54:42+08:00
menu:
  sidebar:
    name: "Go Tool Trace"
    identifier: golang-profiling-go-tool-trace-introduction-by-ray
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [淺談 Go Tool Trace - 1](https://ithelp.ithome.com.tw/articles/10350656)
- [淺談 Go Tool Trace - 2 Go Trace 與使用者自訂追蹤分析](https://ithelp.ithome.com.tw/articles/10351336)
- [淺談 Go Tool Trace - 3 實際分析 Goroutine Analysis](https://ithelp.ithome.com.tw/articles/10352139)
- [Go Tool Trace - 4 從 分析到實戰：最佳化 Goroutine 數量](https://ithelp.ithome.com.tw/articles/10352141)
- [trace](https://pkg.go.dev/cmd/trace@go1.23.0)

**_Trace is an "event timeline", not "sampling statistics"_**

- `go tool trace`: used to inspect **runtime traces**. Its essence is a **time-ordered event stream**, including:
  - goroutine lifecycle/states: create / runnable / running / waiting / syscall
  - scheduler (G/M/P) related events, scheduling latency
  - blocking time distribution (net / sync / syscall)
  - GC events, STW, heap changes (visible in the trace viewer)
- Use `pprof` to find **hot spots**: who burns CPU, who allocates a lot
- Use `trace` to find **latency causes**: **why** it's stuck (scheduling? locks? network? syscalls? GC?)

> Quick intuition:
>
> - "CPU isn't saturated but it's still slow" → start with trace (often blocking / sched)
> - "CPU is maxed out; I want to know the hottest functions" → start with pprof(cpu)

## 1. Standard trace workflow (copy/paste this later)

### 1.1 Produce `trace.out`

Wrap the workload you want to observe with `runtime/trace`.

### 1.2 Open the viewer and inspect the timeline

```bash
go tool trace trace.out
```

> Tip: find the "slowest time window" first, then zoom in, so you don't get overwhelmed by events.

### 1.3 When you need clearer attribution, export the built-in blocking profiles from the trace (will produce `.prof`)

```bash
go tool trace -pprof=sched   trace.out > sched.prof
go tool trace -pprof=net     trace.out > net.prof
go tool trace -pprof=sync    trace.out > sync.prof
go tool trace -pprof=syscall trace.out > syscall.prof
```

### 1.4 Use `pprof` to inspect `.prof` (top / call graph / list)

```bash
go tool pprof sched.prof
(pprof) top
(pprof) web
(pprof) list main.worker
```

You can also open the HTTP UI directly:

```bash
go tool pprof -http :0 sched.prof
```

## 2. What I'm looking at in the trace viewer

### 2.1 First check: is it a scheduling problem? `sched` (Scheduler latency / runnable waiting too long)

- Symptom: lots of goroutines appear to be waiting; CPU usage is low, or latency is jittery
- First:
  1. Export `sched.prof` → `pprof top`
  2. In the trace viewer, check whether runnable → running latency is long
- Common causes:
  - goroutine explosion (over fan-out)
  - `GOMAXPROCS` / P pressure (most of the time it's because I spawned too many goroutines)
  - worker pool not controlled (dumping all work into a goroutine sea)

### 2.2 Check "what kind of blocking is it": `net / sync / syscall`

- `net`: blocked on network I/O (HTTP / DB / RPC / DNS/timeout)
- `sync`: blocked on locks / WaitGroup / Cond / channel coordination (lock contention)
- `syscall`: blocked on OS syscalls (file I/O, DNS, other blocking syscalls)

> 1. `sched` first (scheduling latency)
> 2. then `net/sync/syscall` to find the blocking root cause
> 3. finally return to the timeline to verify "did the event pattern change after the fix?"

## 3. The key to readability: add custom Task / Region

> Without task/region, the trace often becomes just runtime events:
> I can tell it's "slow", but it's hard to map to "business steps".

### 3.1 Task: connect "one unit of work" end-to-end (e.g., a job / a request)

- `trace.NewTask(ctx, "name")` → creates a task node you can search/aggregate in the viewer

### 3.2 Region: label what "this step" is doing (e.g., WriteFile / HTTPGet / CPUWork)

- `trace.WithRegion(ctx, "step", func(){ ... })`
- Split steps that tend to block into regions (I/O, locks, RPC, serialization, compute)

## 4. Optimization/validation strategy with trace

### 4.1 Start with Goroutine Analysis to find the "largest group / most expensive"

1. Is it "too many goroutines"? (scheduler pressure, sched latency)
2. Or "a few goroutines are slow"? (net/sync/syscall/GC)

### 4.2 If it's allocation/GC pressure: use `sync.Pool` for object reuse

- Only use a pool when there are "lots of short-lived large buffers" (e.g., repeatedly `make([]byte, 2MB)`)
- Use trace to observe:
  - whether GC events decrease and stutter/jank improves
  - whether elapsed time decreases
  - whether memory becomes unacceptable (pool can increase RSS)

### 4.3 If it's sched pressure: tune goroutine/worker count (D18)

**A reasonable goroutine/worker count depends on the waiting/blocking ratio**

1. Baseline: run once with `-workers 1000` (intentionally large)
2. Use trace to see whether `sched` "blows up"
3. Reduce workers to a range where "CPU stays utilized and runnable latency drops"
4. Validate every change via trace (not only elapsed time)

## 5. Example (trace + task/region + pool + workers)

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
			// Fill some data to avoid being all zeros (helps simulate CPU/IO)
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
		// One task per unit of work so the trace viewer can aggregate/search by name
		taskCtx, taskSpan := trace.NewTask(ctx, fmt.Sprintf("worker=%d task=%d", id, taskID))

		// Get payload (optional sync.Pool)
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
			// Do a bit of CPU work (hash)
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
			// Read a small amount of body so network isn't the only bottleneck
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

	// Start/stop trace & cpu profiling around the workload we want to observe
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

## 6. Command list

### 6.1 Produce trace (baseline: intentionally large workers)

```bash
go run main.go -workers 1000 -tasks 2000 -enable-trace=true -trace trace.out
```

### 6.2 Open trace viewer

```bash
go tool trace trace.out
```

### 6.3 Export blocking profiles (trace → pprof)

```bash
go tool trace -pprof=sched   trace.out > sched.prof
go tool trace -pprof=net     trace.out > net.prof
go tool trace -pprof=sync    trace.out > sync.prof
go tool trace -pprof=syscall trace.out > syscall.prof
```

### 6.4 Inspect with pprof (interactive)

```bash
go tool pprof sched.prof
(pprof) top
(pprof) web
(pprof) list main.worker
```

Or open the UI:

```bash
go tool pprof -http :0 sched.prof
go tool pprof -http :0 net.prof
go tool pprof -http :0 sync.prof
go tool pprof -http :0 syscall.prof
```

### 6.5 Worker count experiments (record results in the same table)

```bash
# Large (amplifies sched problems)
go run main.go -workers 1000 -tasks 2000 -trace trace_1000.out

# Medium
go run main.go -workers 31 -tasks 2000 -trace trace_31.out

# Smaller / fine-tune
go run main.go -workers 25 -tasks 2000 -trace trace_25.out
```

### 6.6 Enable CPU profile (to compare with pprof(cpu) hot spots)

```bash
go run main.go -workers 31 -tasks 2000 -enable-cpu=true -cpuprofile cpu.prof -trace trace.out
go tool pprof -http :0 cpu.prof
```

## 7. Trace conclusions

### 7.1 First decide: which category is the slowdown?

- **sched** high: runnable waiting too long → reduce goroutine/worker count, apply backpressure
- **sync** high: lock/sync blocking → find contention hot spots (shorten critical sections, split locks, reduce sharing)
- **net** high: network blocked → inspect downstream latency, timeouts, connection pools, DNS
- **syscall** high: OS syscall blocked → inspect file I/O, disk, DNS, other blocking syscalls
- **GC obvious**: inspect allocation patterns, short-lived large objects, whether pool or fewer allocs help

### 7.2 Do "before/after" comparisons

After changing worker count / adding pool / changing sync, check:

1. elapsed time
2. whether `sched/net/sync/syscall` profile shares moved
3. whether the event pattern on the trace timeline changed (sometimes you just shifted the bottleneck)

## 8. How to decide whether to use an Object Pool

1. There are truly many repeated allocations (especially large buffers) and lifetimes are short
2. Trace/GC metrics show GC pressure or allocation cost is a bottleneck
3. Accept that pool may increase peak memory (trade memory for speed)

In the example:

```bash
go run main.go -workers 31 -tasks 2000 -use-pool=true -trace trace_pool.out
```

Then export profiles for comparison:

```bash
go tool trace -pprof=sched trace_pool.out > sched_pool.prof
go tool pprof -http :0 sched_pool.prof
```

## 9. goroutine/worker count: treat it as "trace-validated tuning"

> Workers are not "the more the better". When runnable waiting (sched latency) rises, pull workers back into a reasonable range.

- Use `-workers 1000` to amplify the issue → trace: check whether `sched` explodes
- Gradually reduce workers (e.g., 200 → 100 → 50 → 31 → 25)
- Find the range where "elapsed improves + sched latency clearly drops"
- Then do a second optimization pass on `net/sync/syscall` (avoid merely shifting the bottleneck)

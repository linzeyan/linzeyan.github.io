---
title: "More Powerful Go Execution Tracing"
date: 2024-05-07T11:45:57+08:00
menu:
  sidebar:
    name: "More Powerful Go Execution Tracing"
    identifier: go-trace
    weight: 10
tags: ["Links", "Go", "trace"]
categories: ["Links", "Go", "trace"]
hero: images/hero/go.svg
---

- [More Powerful Go Execution Tracing](https://colobu.com/2024/03/18/execution-traces-2024/)

### runtime/trace

### golang.org/x/exp/trace

#### Flight Recording

```go
// Set up the flight recorder
fr := trace.NewFlightRecorder()
fr.Start()
// Set up and run the HTTP server
var once sync.Once
http.HandleFunc("/my-endpoint", func(w http.ResponseWriter, r *http.Request) {
    start := time.Now()
    // Do some work
    doWork(w, r)
    // Got a long-running request, take a snapshot
    if time.Since(start) > 300*time.Millisecond {
        // We only do this once for simplicity; you can do it multiple times
        once.Do(func() {
            // Capture snapshot
            var b bytes.Buffer
            _, err = fr.WriteTo(&b)
            if err != nil {
                log.Print(err)
                return
            }
            // Write snapshot to file
            if err := os.WriteFile("trace.out", b.Bytes(), 0o755); err != nil {
                log.Print(err)
                return
            }
        })
    }
})
log.Fatal(http.ListenAndServe(":8080", nil))
```

#### Trace Reader API

```go
// Start reading trace data from stdin.
r, err := trace.NewReader(os.Stdin)
if err != nil {
    log.Fatal(err)
}
var blocked int
var blockedOnNetwork int
for {
    // Read event
    ev, err := r.ReadEvent()
    if err == io.EOF {
        break
    } else if err != nil {
        log.Fatal(err)
    }
    // Handle it
    if ev.Kind() == trace.EventStateTransition {
        st := ev.StateTransition()
        if st.Resource.Kind == trace.ResourceGoroutine {
            id := st.Resource.Goroutine()
            from, to := st.GoroutineTransition()
            // Find blocked goroutines and count them
            if from.Executing() && to == trace.GoWaiting {
                blocked++
                if strings.Contains(st.Reason, "network") {
                    blockedOnNetwork++
                }
            }
        }
    }
}

// Print the values we need
p := 100 * float64(blockedOnNetwork) / float64(blocked)
fmt.Printf("%2.3f%% instances of goroutines blocking were to block on the network\n", p)
```

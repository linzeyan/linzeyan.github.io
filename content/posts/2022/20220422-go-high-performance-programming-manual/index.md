---
title: "Go High-Performance Programming Handbook (Long Read)"
date: 2022-04-22T18:01:43+08:00
menu:
  sidebar:
    name: "Go High-Performance Programming Handbook (Long Read)"
    identifier: go-high-performance-programming-manual
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go High-Performance Programming Handbook (Long Read)](https://mp.weixin.qq.com/s/iSxWFsnNLGgilzKIsSDBgg)

#### Common data structures

**Reflection is nice, but don't overuse it**

- Prefer `strconv` over `fmt`
- A small amount of repetition is not worse than reflection
- Use `binary.Read` and `binary.Write` with caution
  - `binary.Read` and `binary.Write` use reflection and are slow. If you need these two functions, implement the required logic manually instead of using them directly.

**Avoid repeated conversions from string to byte slice**

**Specify container (slice/map) capacity**

**String concatenation**

- For inline concatenation, use the `+` operator
- For non-inline concatenation, use `strings.Builder`

**Iterate `[]struct{}` with indexes instead of `range`**

> There is no performance difference between the two index-based ways of iterating `[]struct`, but iterating elements of `[]struct` with `range` is very slow.
>
> When using `range` to iterate `[]*struct`, performance is the same as indexes.

#### Memory management

**Use empty structs to save memory**

**Struct layout should consider memory alignment**

> When the CPU accesses memory, it does not access byte by byte; it accesses in word-size units. For example, on a 32-bit CPU, the word size is 4 bytes, so the CPU accesses memory in 4-byte units.
> The purpose is to reduce the number of memory accesses and increase memory throughput. For example, to read 8 bytes, reading 4 bytes at a time only requires two reads.

**Reduce escapes and keep variables on the stack**

- Variable escape generally occurs in these cases:
  - Large variables
  - Variable size is unknown
  - Variable type is unknown
  - Return pointer
  - Return reference
  - Closure
- Small copies are better than references
  - Typically <64KB; local variables will not escape to the heap.
- Return value vs return pointer
  - Passing by value copies the whole object; passing by pointer copies only the address and points to the same object. Returning a pointer reduces value copying but causes heap allocation and increases GC overhead. In scenarios with frequent object creation and deletion, pointer passing can severely impact performance due to GC overhead.
  - In general, return a pointer for structs that need to be modified or are large in memory; for read-only, small structs, returning by value can be faster.
- Return concrete types
  - If the variable type is not concrete, it will escape to the heap. Therefore, if a function return type can be concrete, avoid using interface{}.

**Reuse objects with `sync.Pool`**

> `sync.Pool` is scalable and concurrency-safe, and its capacity is only limited by memory. Objects stored in the pool are automatically cleared when they are inactive.
>
> For many cases that repeatedly allocate and free memory, `sync.Pool` is a good choice. Frequent allocations and deallocations put pressure on GC; in severe cases it can cause CPU spikes. `sync.Pool` can cache temporarily unused objects and reuse them next time without reallocation, reducing GC pressure and improving performance.
>
> In short: save and reuse temporary objects, reduce memory allocations, and lower GC pressure.

#### Concurrency programming

**About locks**

- Lock-free
  - Not all concurrency needs locks. Reducing lock granularity, or even using lock-free designs, can improve concurrency.
  - Lock-free data structures
    - Atomic operations supported by hardware can implement lock-free data structures. <mark>Atomic operations can ensure concurrency safety in a lock-free manner</mark>, and performance can scale linearly with CPU count. Many languages provide CAS atomic operations (such as Go's `atomic` package and C++11's atomic library), which can be used to implement lock-free data structures such as lock-free linked lists.
  - Serial lock-free
    - Serial lock-free is an idea: <mark>avoid concurrent access to shared resources</mark> by having each concurrent operation access its own exclusive resource, achieving serialized access to avoid locks. Different scenarios have different implementations. For example, in network I/O, change from a single-reactor multi-thread model to a master/worker reactor multi-thread model to avoid locking reads on the same message queue.
- Reduce lock contention
  - If locking is unavoidable, use sharding to reduce the number of locks, which improves overall performance.
  - For example, excellent Go local cache components like `bigcache`, `go-cache`, and `freecache` all implement sharding; each shard has its own lock, reducing lock contention and improving performance.
- Prefer shared locks over mutexes
  - A mutex can only be held by one goroutine. A shared lock can be held by multiple goroutines at the same time.
  - The Go standard library provides mutexes (`sync.Mutex`) and RWMutexes (`sync.RWMutex`). <mark>RWMutex is a concrete implementation of a shared lock</mark>.

**Limit the number of goroutines**

> Each goroutine consumes at least 2KB. Assuming the machine has 4GB of memory, at most 4GB/2KB = 1M goroutines can exist concurrently.

- Goroutine pooling
  - `Jeffail/tunny` / `panjf2000/ants`

**Use `sync.Once` to avoid duplicate execution**

**Use `sync.Cond` to notify goroutines**

> `sync.Cond` is a condition variable based on a mutex/RWMutex. It coordinates goroutines that want to access shared resources. When the shared resource state changes, `sync.Cond` can notify goroutines blocked while waiting for the condition.

We implement a simple example: three goroutines call Wait() to wait, and another goroutine calls Broadcast() to wake all waiting goroutines.

- done is the condition that multiple goroutines are waiting on.
- read() calls Wait() and waits for the notification until done is true.
- write() receives data; after finishing, it sets done to true and calls Broadcast() to notify all waiting goroutines.
- write() sleeps for 1s, partly to simulate latency and partly to ensure the three read goroutines have reached Wait() and are waiting. The main function sleeps for 3s to ensure all operations complete.

```go
var done = false

func read(name string, c *sync.Cond) {
 c.L.Lock()
 for !done {
  c.Wait()
 }
 log.Println(name, "starts reading")
 c.L.Unlock()
}

func write(name string, c *sync.Cond) {
 log.Println(name, "starts writing")
 time.Sleep(time.Second)
 done = true
 log.Println(name, "wakes all")
 c.Broadcast()
}

func main() {
 cond := sync.NewCond(&sync.Mutex{})

 go read("reader1", cond)
 go read("reader2", cond)
 go read("reader3", cond)
 write("writer", cond)

 time.Sleep(time.Second * 3)
}
```

```bash
$ go run main.go
2022/03/07 17:20:09 writer starts writing
2022/03/07 17:20:10 writer wakes all
2022/03/07 17:20:10 reader3 starts reading
2022/03/07 17:20:10 reader1 starts reading
2022/03/07 17:20:10 reader2 starts reading
```

{{< alert type="warning" >}}

- `sync.Cond` cannot be copied
  - The reason `sync.Cond` cannot be copied is not because it embeds a Locker. The Mutex/RWMutex pointer passed to NewCond can be copied.
  - The main reason is that `sync.Cond` maintains a goroutine notify queue (notifyList). If the queue is copied, then in concurrent scenarios, different goroutines would operate on different notifyList.wait/notifyList.notify, and some goroutines could block forever.
- Wake up waiting goroutines in order: first in, first out.
- Lock before calling Wait()
  - Before calling Wait(), you must acquire the condition variable's lock because the waiting queue must be mutated mutually exclusively. The lock is reacquired before Wait() returns.
    {{< /alert >}}

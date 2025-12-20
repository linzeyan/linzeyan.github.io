---
title: "Go语言高性能编程手册（万字长文）"
date: 2022-04-22T18:01:43+08:00
menu:
  sidebar:
    name: "Go语言高性能编程手册（万字长文）"
    identifier: go-high-performance-programming-manual
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [Go 语言高性能编程手册（万字长文）](https://mp.weixin.qq.com/s/iSxWFsnNLGgilzKIsSDBgg)

#### 常用数据结构

**反射虽好，切莫贪杯**

- 优先使用 `strconv` 而不是 `fmt`
- 少量的重复不比反射差
- 慎用 `binary.Read` 和 `binary.Write`
  - `binary.Read` 和 `binary.Write` 使用反射并且很慢。如果有需要用到这两个函数的地方，我们应该手动实现这两个函数的相关功能，而不是直接去使用它们。

**避免重复的字符串到字节切片的转换**

**指定容器(slice/map)容量**

**字符串拼接方式**

- 行内拼接字符串推荐使用运算符 `+`
- 非行内拼接字符串推荐使用 `strings.Builder`

**遍历 `[]struct{}` 使用下标而不是 `range`**

> 两种通过 index 遍历 `[]struct` 性能没有差别，但是 `range` 遍历 `[]struct` 中元素时，性能非常差。
>
> `range` 遍历 `[]*struct` 中元素时，與下标性能没有差别。

#### 内存管理

**使用空结构体节省内存**

**struct 布局要考虑内存对齐**

> CPU 访问内存时，并不是逐个字节访问，而是以字长（word size）为单位访问。比如 32 位的 CPU ，字长为 4 字节，那么 CPU 访问内存的单位也是 4 字节。
> 这么设计的目的，是减少 CPU 访问内存的次数，加大 CPU 访问内存的吞吐量。比如同样读取 8 个字节的数据，一次读取 4 个字节那么只需要读取 2 次。

**减少逃逸，将变量限制在栈上**

- 变量逃逸一般发生在如下几种情况：
  - 变量较大
  - 变量大小不确定
  - 变量类型不确定
  - 返回指针
  - 返回引用
  - 闭包
- 小的拷贝好过引用
  - 一般是 <64KB，局部变量将不会逃逸到堆上。
- 返回值 VS 返回指针
  - 值传递会拷贝整个对象，而指针传递只会拷贝地址，指向的对象是同一个。返回指针可以减少值的拷贝，但是会导致内存分配逃逸到堆中，增加垃圾回收（GC）的负担。在对象频繁创建和删除的场景下，传递指针导致的 GC 开销可能会严重影响性能。
  - 一般情况下，对于需要修改原对象值，或占用内存比较大的结构体，选择返回指针。对于只读的占用内存较小的结构体，直接返回值能够获得更好的性能。
- 返回值使用确定的类型
  - 如果变量类型不确定，那么将会逃逸到堆上。所以，函数返回值如果能确定的类型，就不要使用 interface{}。

**`sync.Pool` 复用对象**

> `sync.Pool` 是可伸缩的，同时也是并发安全的，其容量仅受限于内存的大小。存放在池中的对象如果不活跃了会被自动清理。
>
> 对于很多需要重复分配、回收内存的地方，`sync.Pool` 是一个很好的选择。频繁地分配、回收内存会给 GC 带来一定的负担，严重的时候会引起 CPU 的毛刺，而 `sync.Pool` 可以将暂时不用的对象缓存起来，待下次需要的时候直接使用，不用再次经过内存分配，复用对象的内存，减轻 GC 的压力，提升系统的性能。
>
> 一句话总结：用来保存和复用临时对象，减少内存分配，降低 GC 压力。

#### 并发编程

**关于锁**

- 无锁化
  - 并非所有的并发都需要加锁。适当地降低锁的粒度，甚至采用无锁化的设计，更能提升并发能力。
  - 无锁数据结构
    - 利用硬件支持的原子操作可以实现无锁的数据结构，<mark>原子操作可以在 lock-free 的情况下保证并发安全</mark>，并且它的性能也能做到随 CPU 个数的增多而线性扩展。很多语言都提供 CAS 原子操作（如 Go 中的 `atomic` 包和 C++11 中的 atomic 库），可以用于实现无锁数据结构，如无锁链表。
  - 串行无锁
    - 串行无锁是一种思想，就是<mark>避免对共享资源的并发访问</mark>，改为每个并发操作访问自己独占的资源，达到串行访问资源的效果，来避免使用锁。不同的场景有不同的实现方式。比如网络 I/O 场景下将单 Reactor 多线程模型改为主从 Reactor 多线程模型，避免对同一个消息队列锁读取。
- 减少锁竞争
  - 如果加锁无法避免，则可以采用分片的形式，减少对资源加锁的次数，这样也可以提高整体的性能。
  - 比如 Golang 优秀的本地缓存组件 `bigcache`、`go-cache`、`freecache` 都实现了分片功能，每个分片一把锁，采用分片存储的方式减少加锁的次数从而提高整体性能。
- 优先使用共享锁而非互斥锁
  - 所谓互斥锁，指锁只能被一个 Goroutine 获得。共享锁指可以同时被多个 Goroutine 获得的锁。
  - Go 标准库 sync 提供了两种锁，互斥锁（`sync.Mutex`）和读写锁（`sync.RWMutex`），<mark>读写锁便是共享锁的一种具体实现</mark>。

**限制协程数量**

> 每个协程至少需要消耗 2KB 的空间，那么假设计算机的内存是 4GB，那么至多允许 4GB/2KB = 1M 个协程同时存在。

- 协程池化
  - `Jeffail/tunny` / `panjf2000/ants`

**使用 `sync.Once` 避免重复执行**

**使用 `sync.Cond` 通知协程**

> `sync.Cond` 是基于互斥锁/读写锁实现的条件变量，用来协调想要访问共享资源的那些 Goroutine，当共享资源的状态发生变化的时候，`sync.Cond` 可以用来通知等待条件发生而阻塞的 Goroutine。

我们实现一个简单的例子，三个协程调用 Wait() 等待，另一个协程调用 Broadcast() 唤醒所有等待的协程。

- done 即多个 Goroutine 阻塞等待的条件。
- read() 调用 Wait() 等待通知，直到 done 为 true。
- write() 接收数据，接收完成后，将 done 置为 true，调用 Broadcast() 通知所有等待的协程。
- write() 中的暂停了 1s，一方面是模拟耗时，另一方面是确保前面的 3 个 read 协程都执行到 Wait()，处于等待状态。main 函数最后暂停了 3s，确保所有操作执行完毕。

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

- `sync.Cond` 不能被复制
  - `sync.Cond` 不能被复制的原因，并不是因为其内部嵌套了 Locker。因为 NewCond 时传入的 Mutex/RWMutex 指针，对于 Mutex 指针复制是没有问题的。
  - 主要原因是 `sync.Cond` 内部是维护着一个 Goroutine 通知队列 notifyList。如果这个队列被复制的话，那么就在并发场景下导致不同 Goroutine 之间操作的 notifyList.wait、notifyList.notify 并不是同一个，这会导致出现有些 Goroutine 会一直阻塞。
- 从等待队列中按照顺序唤醒，先进入等待队列，先被唤醒。
- 调用 Wait() 前要加锁
  - 调用 Wait() 函数前，需要先获得条件变量的成员锁，原因是需要互斥地变更条件变量的等待队列。在 Wait() 返回前，会重新上锁。
    {{< /alert >}}

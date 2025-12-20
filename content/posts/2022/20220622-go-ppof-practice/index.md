---
title: "golang pprof 实战"
date: 2022-06-22T15:29:02+08:00
menu:
  sidebar:
    name: "golang pprof 实战"
    identifier: golang-go-ppof-practice
    weight: 10
tags: ["URL", "Go", "pprof"]
categories: ["URL", "Go", "pprof"]
hero: images/hero/go.svg
---

- [golang pprof 实战](https://blog.wolfogre.com/posts/go-ppof-practice/)
- [炸弹程序](https://github.com/wolfogre/go-pprof-practice)

```go
package main

import (
	// 略
	_ "net/http/pprof" // 会自动注册 handler 到 http server，方便通过 http 接口获取程序运行采样报告
	// 略
)

func main() {
	// 略

	runtime.GOMAXPROCS(1) // 限制 CPU 使用数，避免过载
	runtime.SetMutexProfileFraction(1) // 开启对锁调用的跟踪
	runtime.SetBlockProfileRate(1) // 开启对阻塞操作的跟踪

	go func() {
		// 启动一个 http server，注意 pprof 相关的 handler 已经自动注册过了
    // /debug/pprof/
		if err := http.ListenAndServe(":6060", nil); err != nil {
			log.Fatal(err)
		}
		os.Exit(0)
	}()

	// 略
}
```

- http://localhost:6060/debug/pprof/

| 类型         | 描述                       | 备注                                                              |
| ------------ | -------------------------- | ----------------------------------------------------------------- |
| allocs       | 内存分配情况的采样信息     | 可以用浏览器打开，但可读性不高                                    |
| blocks       | 阻塞操作情况的采样信息     | 可以用浏览器打开，但可读性不高                                    |
| cmdline      | 显示程序启动命令及参数     | 可以用浏览器打开，这里会显示 ./go-pprof-practice                  |
| goroutine    | 当前所有协程的堆栈信息     | 可以用浏览器打开，但可读性不高                                    |
| heap         | 堆上内存使用情况的采样信息 | 可以用浏览器打开，但可读性不高                                    |
| mutex        | 锁争用情况的采样信息       | 可以用浏览器打开，但可读性不高                                    |
| profile      | CPU 占用情况的采样信息     | 浏览器打开会下载文件                                              |
| threadcreate | 系统线程创建情况的采样信息 | 可以用浏览器打开，但可读性不高                                    |
| trace        | 程序运行跟踪信息           | 浏览器打开会下载文件，本文不涉及，可另行参阅《深入浅出 Go trace》 |

**排查 CPU 占用过高**

1. 可以看到 CPU 占用相当高，`go tool pprof http://localhost:6060/debug/pprof/profile` 进入一个交互式终端
2. 输入 `top` 命令，查看 CPU 占用较高的调用
3. 很明显，CPU 占用过高是 `github.com/wolfogre/go-pprof-practice/animal/felidae/tiger.(*Tiger).Eat` 造成的。
4. 输入 `list Eat`，查看问题具体在代码的哪一个位置
5. 可以看到，是第 24 行那个一百亿次空循环占用了大量 CPU 时间

接下来有一个扩展操作：图形化显示调用栈信息，这很酷，但是需要你事先在机器上安装 `graphviz`，大多数系统上可以轻松安装它

```bash
brew install graphviz # for macos
apt install graphviz # for ubuntu
yum install graphviz # for centos
```

6. 交互式终端里输入 `web`(虽然这个命令的名字叫"web"，但它的实际行为是产生一个 `.svg` 文件，并调用你的系统里设置的默认打开 `.svg` 的程序打开它)
7. 输入 `exit` 退出 pprof 的交互式终端

**排查内存占用过高**

8. 内存的占用率仍然很高 `go tool pprof http://localhost:6060/debug/pprof/heap`
9. 再一次使用 `top`, `list` 来定问问题代码
10. 这次出问题的地方在 `github.com/wolfogre/go-pprof-practice/animal/muridae/mouse.(*Mouse).Steal`
11. 使用 `web` 来查看图形化展示，可以再次确认问题确实出在这里

**排查频繁内存回收**
`GODEBUG=gctrace=1 ./go-pprof-practice | grep gc`
接下来使用 pprof 排查时，我们在乎的不是什么地方在占用大量内存，而是什么地方在不停地申请内存，这两者是有区别的

12. `go tool pprof http://localhost:6060/debug/pprof/allocs`
13. 可以看到 `github.com/wolfogre/go-pprof-practice/animal/canidae/dog.(*Dog).Run` 会进行无意义的内存申请

**排查协程泄露**
我们在浏览器里可以看到，此时程序的协程数已经多达 106 条 `106 goroutine`

14. `go tool pprof http://localhost:6060/debug/pprof/goroutine`
15. 可能这次问题藏得比较隐晦，但仔细观察还是不难发现，问题在于 `github.com/wolfogre/go-pprof-practice/animal/canidae/wolf.(*Wolf).Drink` 在不停地创建没有实际作用的协程

**排查锁的争用**

16. go tool pprof http://localhost:6060/debug/pprof/mutex
17. 可以看出来这问题出在 `github.com/wolfogre/go-pprof-practice/animal/canidae/wolf.(*Wolf).Howl`。但要知道，在代码中使用锁是无可非议的，并不是所有的锁都会被标记有问题，我们看看这个有问题的锁那儿触雷了。

**排查阻塞操作**

18. `go tool pprof http://localhost:6060/debug/pprof/block`
19. 可以看到，阻塞操作位于 `github.com/wolfogre/go-pprof-practice/animal/felidae/cat.(*Cat).Pee`

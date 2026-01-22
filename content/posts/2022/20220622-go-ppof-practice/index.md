---
title: "Go pprof in Practice"
date: 2022-06-22T15:29:02+08:00
menu:
  sidebar:
    name: "Go pprof in Practice"
    identifier: golang-go-ppof-practice
    weight: 10
tags: ["Links", "Go", "pprof"]
categories: ["Links", "Go", "pprof"]
hero: images/hero/go.svg
---

- [Go pprof in Practice](https://blog.wolfogre.com/posts/go-ppof-practice/)
- [Bomb program](https://github.com/wolfogre/go-pprof-practice)

```go
package main

import (
	// omitted
	_ "net/http/pprof" // auto-register handlers to the HTTP server for profiling via HTTP
	// omitted
)

func main() {
	// omitted

	runtime.GOMAXPROCS(1) // limit CPU usage to avoid overload
	runtime.SetMutexProfileFraction(1) // enable lock contention profiling
	runtime.SetBlockProfileRate(1) // enable blocking operation profiling

	go func() {
		// start an HTTP server; pprof handlers have already been registered
    // /debug/pprof/
		if err := http.ListenAndServe(":6060", nil); err != nil {
			log.Fatal(err)
		}
		os.Exit(0)
	}()

	// omitted
}
```

- http://localhost:6060/debug/pprof/

| Type         | Description                         | Notes                                                                    |
| ------------ | ----------------------------------- | ------------------------------------------------------------------------ |
| allocs       | Samples of memory allocations       | Can open in a browser, but readability is low                            |
| blocks       | Samples of blocking operations      | Can open in a browser, but readability is low                            |
| cmdline      | Show program startup command/args   | Can open in a browser; shows ./go-pprof-practice                         |
| goroutine    | Stacks of all current goroutines    | Can open in a browser, but readability is low                            |
| heap         | Samples of heap memory usage        | Can open in a browser, but readability is low                            |
| mutex        | Samples of lock contention          | Can open in a browser, but readability is low                            |
| profile      | Samples of CPU usage                | Opening in a browser downloads a file                                    |
| threadcreate | Samples of system thread creation   | Can open in a browser, but readability is low                            |
| trace        | Program execution traces            | Opening in a browser downloads a file; not covered here, see Go trace    |

**Investigate high CPU usage**

1. You can see CPU usage is quite high. Run `go tool pprof http://localhost:6060/debug/pprof/profile` to enter an interactive terminal.
2. Enter `top` to view calls with high CPU usage.
3. Clearly, high CPU usage is caused by `github.com/wolfogre/go-pprof-practice/animal/felidae/tiger.(*Tiger).Eat`.
4. Enter `list Eat` to see the exact code location.
5. You can see that line 24 runs a 10-billion-iteration empty loop, consuming lots of CPU time.

Next is an extended step: visualize the call stack. It is cool, but you need to install `graphviz` first. It is easy to install on most systems.

```bash
brew install graphviz # for macos
apt install graphviz # for ubuntu
yum install graphviz # for centos
```

6. In the interactive terminal, enter `web` (although the command name is "web", it actually generates an `.svg` file and opens it with your default `.svg` viewer).
7. Enter `exit` to leave the pprof interactive terminal.

**Investigate high memory usage**

8. Memory usage is still high: `go tool pprof http://localhost:6060/debug/pprof/heap`
9. Use `top` and `list` again to locate the problematic code.
10. This time, the issue is in `github.com/wolfogre/go-pprof-practice/animal/muridae/mouse.(*Mouse).Steal`.
11. Use `web` to view the visualization and confirm the problem is indeed here.

**Investigate frequent GC**

`GODEBUG=gctrace=1 ./go-pprof-practice | grep gc`

When using pprof, what we care about is not just where memory is consumed, but where memory is being allocated repeatedly. These are different.

12. `go tool pprof http://localhost:6060/debug/pprof/allocs`
13. You can see `github.com/wolfogre/go-pprof-practice/animal/canidae/dog.(*Dog).Run` performs meaningless allocations.

**Investigate goroutine leaks**

In the browser, you can see the number of goroutines has reached 106: `106 goroutine`.

14. `go tool pprof http://localhost:6060/debug/pprof/goroutine`
15. The issue is a bit subtle this time, but you can still see that `github.com/wolfogre/go-pprof-practice/animal/canidae/wolf.(*Wolf).Drink` keeps creating useless goroutines.

**Investigate lock contention**

16. go tool pprof http://localhost:6060/debug/pprof/mutex
17. The problem is at `github.com/wolfogre/go-pprof-practice/animal/canidae/wolf.(*Wolf).Howl`. Note that using locks is not inherently wrong; not all locks are problematic. Let's see why this one triggers.

**Investigate blocking operations**

18. `go tool pprof http://localhost:6060/debug/pprof/block`
19. The blocking operation is in `github.com/wolfogre/go-pprof-practice/animal/felidae/cat.(*Cat).Pee`

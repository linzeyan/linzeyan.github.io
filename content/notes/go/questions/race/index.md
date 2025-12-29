---
title: Race
weight: 120
menu:
  notes:
    name: Race
    identifier: notes-go-questions-race
    parent: notes-go-questions
    weight: 20
---

{{< note title="race" >}}

```go
type Stats struct {
    mutex sync.Mutex

    counters map[string]int
}

func (s *Stats) Snapshot() map[string]int {
    s.mutex.Lock()
    defer s.mutex.Unlock()

    return s.counters
}

func (s *Stats) Add(name string, num int) {
    s.mutex.Lock()
    defer s.mutex.Unlock()
    s.counters[name] = num
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-golang">func (s *Stats) Snapshot() map[string]int {
	s.mutex.Lock()
	defer s.mutex.Unlock()
	result := make(map[string]int, len(s.counters))
	for k, v := range s.counters {
		result[k] = v
	}
	return result
}
</code></pre></details>
{{< /note >}}

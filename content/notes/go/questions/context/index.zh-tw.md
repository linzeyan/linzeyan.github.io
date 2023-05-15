---
title: Context
weight: 120
menu:
  notes:
    name: Context
    identifier: notes-go-questions-context
    parent: notes-go-questions
    weight: 20
---

{{< note title="context" >}}

```go
package main

import (
	"context"
	"fmt"
)

func f(ctx context.Context) {
	context.WithValue(ctx, "foo", -6)
}

func main() {
	ctx := context.TODO()
	f(ctx)
	fmt.Println(ctx.Value("foo"))
}
```

- A. -6
- B. 0
- C. `<nil>`
- D: panic

<details>
<summary>Answer</summary>
<pre>
<code>C
</code></pre></details>
{{< /note >}}



{{< note title="context1" >}}

```go
package main

import(
	"fmt"
	"encoding/json"
	"context"
)

func main() {
	data, _ := json.Marshal(context.WithValue(context.Background(), "a", "b"))
	fmt.Println(string(data))
}
```

<details>
<summary>Answer</summary>
<pre>
<code class="language-shell">{"Context":0}
</code></pre></details>
{{< /note >}}

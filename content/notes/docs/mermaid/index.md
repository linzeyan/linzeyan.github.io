---
title: markdown notes
weight: 100
menu:
  notes:
    name: mermaid
    identifier: notes-mermaid
    parent: notes-docs
    weight: 10
---

{{< note title="details" >}}

<details>
<summary>看我</summary>
你看不到我
看不到我
</details>

<!-- 你看不到我看不到我 -->

<!--
你看不到我
看不到我
-->

{{< /note >}}

{{< note title="link" >}}

```markdown
flowchart LR
A --o B
B --x C

    D o--o E
    E <--> F
    F x--x G
```

{{< /note >}}

{{< note title="shapes" >}}

```markdown
graph LR
id1[方框]
id2(帶有圓角的方框)
id3([體育場形狀])
id4[[子例程]]
id5[(圓柱狀)]
id6((圓形))
id7>非對稱形狀]
id8{菱形}
id9{{六角形}}
id10[/平行四邊形 1/]
id11[\平行四邊形 2\]
id12[/梯形 1\]
id13[\梯形 2/]
id14(((雙圓)))
```

{{< /note >}}

{{< note title="subgraphs" >}}

```markdown
flowchart TD
c1-->a2

    subgraph one
    a1-->a2
    end

    subgraph "`**two**`"
    b1-->b2
    end

    subgraph three
    c1-->c2
    end
```

{{< /note >}}

{{< note title="sequence" >}}

```markdown
sequenceDiagram
participant Alice
participant Bob
Alice->>John: Hello John, how are you?
loop Healthcheck
John->John: Fight against hypochondria
end
Note right of John: Rational thoughts <br/>prevail...
John-->Alice: Great!
John->Bob: How about you?
Bob-->John: Jolly good!
```

{{< /note >}}

{{< note title="gantt" >}}

```markdown
gantt
dateFormat YYYY-MM-DD
title Adding GANTT diagram functionality to mermaid
section A section
Completed task :done, des1, 2014-01-06,2014-01-08
Active task :active, des2, 2014-01-09, 3d
Future task : des3, after des2, 5d
Future task2 : des4, after des3, 5d
section Critical tasks
Completed task in the critical line :crit, done, 2014-01-06,24h
Implement parser and jison :crit, done, after des1, 2d
Create tests for parser :crit, active, 3d
Future task in critical line :crit, 5d
Create tests for renderer :2d
Add to mermaid :1d
```

{{< /note >}}

{{< note title="class" >}}

```markdown
classDiagram
Class01 <|-- AveryLongClass : Cool
Class03 _-- Class04
Class05 o-- Class06
Class07 .. Class08
Class09 --> C2 : Where am i?
Class09 --_ C3
Class09 --|> Class07
Class07 : equals()
Class07 : Object[] elementData
Class01 : size()
Class01 : int chimp
Class01 : int gorilla
Class08 <--> C2: Cool label
```

{{< /note >}}

{{< note title="state" >}}

```markdown
stateDiagram-v2
open: Open Door
closed: Closed Door
locked: Locked Door
open --> closed: Close
closed --> locked: Lock
locked --> closed: Unlock
closed --> open: Open
```

{{< /note >}}

{{< note title="git" >}}

```markdown
gitGraph:
options
{
"nodeSpacing": 150,
"nodeRadius": 10
}
end
commit
branch newbranch
checkout newbranch
commit
commit
checkout master
commit
commit
merge newbranch
```

{{< /note >}}

{{< mermaid align="left" >}}
graph LR
A --- B
A ---|text| B
C --> D
C -->|text| D
E -.- F
E -.-|text| F
G -.-> H
G -.->|text| H
I === J
I ===|text| J
{{< /mermaid >}}

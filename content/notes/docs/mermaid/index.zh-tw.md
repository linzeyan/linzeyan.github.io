---
title: mermaid notes
weight: 100
menu:
  notes:
    name: mermaid
    identifier: notes-docs-mermaid
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

- [classDiagram](/notes/docs/mermaid/img/class_1.svg)

{{< /note >}}

{{< note title="flow-link" >}}

```markdown
flowchart LR
A --o B
B --x C

D o--o E
E <--> F
F x--x G
```

- [flowchart](/notes/docs/mermaid/img/link.svg)

{{< /note >}}

{{< note title="flow-link1" >}}

- [code](/notes/docs/mermaid/img/link1)
- [flowchart](/notes/docs/mermaid/img/link1.svg)

{{< /note >}}

{{< note title="flow-shapes" >}}

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

- [flowchart](/notes/docs/mermaid/img/shapes.svg)

{{< /note >}}

{{< note title="flow-subgraphs" >}}

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

- [flowchart](/notes/docs/mermaid/img/subgraphs.svg)

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

- [gantt](/notes/docs/mermaid/img/gantt_1.svg)

{{< /note >}}

{{< note title="git" >}}

```markdown
gitGraph
commit
commit
branch develop
checkout develop
commit
commit
checkout main
merge develop
commit
commit
```

- [git](/notes/docs/mermaid/img/git_1.svg)

{{< /note >}}

{{< note title="er" >}}

```markdown
erDiagram
CUSTOMER }|..|{ DELIVERY-ADDRESS : has
CUSTOMER ||--o{ ORDER : places
CUSTOMER ||--o{ INVOICE : "liable for"
DELIVERY-ADDRESS ||--o{ ORDER : receives
INVOICE ||--|{ ORDER : covers
ORDER ||--|{ ORDER-ITEM : includes
PRODUCT-CATEGORY ||--|{ PRODUCT : contains
PRODUCT ||--o{ ORDER-ITEM : "ordered in"
```

- [erDiagram](/notes/docs/mermaid/img/er_1.svg)

{{< /note >}}
{{< note title="journey" >}}

```markdown
journey
title My working day
section Go to work
Make tea: 5: Me
Go upstairs: 3: Me
Do work: 1: Me, Cat
section Go home
Go downstairs: 5: Me
Sit down: 3: Me
```

- [erDiagram](/notes/docs/mermaid/img/journey_1.svg)

{{< /note >}}

{{< note title="pie" >}}

```markdown
pie title Pets adopted by volunteers
"Dogs" : 386
"Cats" : 85
"Rats" : 15
```

- [pie](/notes/docs/mermaid/img/pie_1.svg)

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

- [sequenceDiagram](/notes/docs/mermaid/img/sequence_1.svg)

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

- [stateDiagram-v2](/notes/docs/mermaid/img/state_1.svg)

{{< /note >}}

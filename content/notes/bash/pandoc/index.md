---
title: Pandoc Command
weight: 100
menu:
  notes:
    name: pandoc
    identifier: notes-bash-pandoc
    parent: notes-bash
    weight: 10
---

{{< note title="texlive" >}}

```bash
# $ brew install textlive
# $ npm i -g mermaid-filter
# Render mermaid
pandoc -F mermaid-filter -o readme.pdf readme.md
```

{{< /note >}}

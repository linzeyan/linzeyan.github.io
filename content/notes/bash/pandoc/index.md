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

- macOS

```bash
# brew install textlive
# npm i -g mermaid-filter
# Render mermaid
pandoc -F mermaid-filter -o readme.pdf readme.md
```

- Ubuntu

```bash
# sudo apt install pandoc -y
# sudo apt-get -y install texlive-latex-recommended texlive-pictures texlive-latex-extra texlive-fonts-recommended
# npm i -g mermaid-filter
pandoc -F mermaid-filter -o readme.pdf readme.md
```

{{< /note >}}

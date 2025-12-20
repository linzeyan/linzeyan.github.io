---
title: "Running GitHub Actions for Certain Commit Messages"
date: 2020-10-11T23:13:22+08:00
menu:
  sidebar:
    name: "Running GitHub Actions for Certain Commit Messages"
    identifier: github-action-running-github-actions-for-certain-commit-messages
    weight: 10
tags: ["URL", "Github"]
categories: ["URL", "Github"]
hero: images/hero/github.png
---

- [Running GitHub Actions for Certain Commit Messages](https://ryangjchandler.co.uk/articles/running-github-actions-for-certain-commit-messages)

Now, whenever I push a `wip` commit or any commit that contains the word `wip`, it will be marked as skipped inside of GitHub actions.

```yaml
jobs:
  format:
    runs-on: ubuntu-latest
    if: "! contains(github.event.head_commit.message, 'wip')"
```

Any commit that contains `[build]` will now trigger these jobs, everything else will be skipped.

```yaml
jobs:
  format:
    runs-on: ubuntu-latest
    if: "contains(github.event.head_commit.message, '[build]')"
```

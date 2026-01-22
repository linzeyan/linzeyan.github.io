---
title: "針對特定 Commit Message 觸發 GitHub Actions"
date: 2020-10-11T23:13:22+08:00
menu:
  sidebar:
    name: "針對特定 Commit Message 觸發 GitHub Actions"
    identifier: github-action-running-github-actions-for-certain-commit-messages
    weight: 10
tags: ["Links", "Github"]
categories: ["Links", "Github"]
hero: images/hero/github.png
---

- [針對特定 Commit Message 觸發 GitHub Actions](https://ryangjchandler.co.uk/articles/running-github-actions-for-certain-commit-messages)

現在，只要我推送 `wip` commit 或任何包含 `wip` 的 commit，就會在 GitHub Actions 中被標記為跳過。

```yaml
jobs:
  format:
    runs-on: ubuntu-latest
    if: "! contains(github.event.head_commit.message, 'wip')"
```

任何包含 `[build]` 的 commit 會觸發這些工作，其他則會被跳過。

```yaml
jobs:
  format:
    runs-on: ubuntu-latest
    if: "contains(github.event.head_commit.message, '[build]')"
```

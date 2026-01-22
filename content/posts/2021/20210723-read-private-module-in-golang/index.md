---
title: "Go Modules workflow for private Git repositories"
date: 2021-07-23T09:40:39+08:00
menu:
  sidebar:
    name: "Go Modules workflow for private Git repositories"
    identifier: golang-read-private-module-in-golang
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Go Modules workflow for private Git repositories](https://blog.wu-boy.com/2020/03/read-private-module-in-golang/)

1. `go env -w GOPRIVATE=github.com/appleboy`
   1. `go env -w GONOPROXY=github.com/appleboy`
   2. `go env -w GONOSUMDB=github.com/appleboy`
1. `git config --global url."https://$USERNAME:$ACCESS_TOKEN@github.com".insteadOf "https://github.com"`
   1. `git config --global url.ssh://git@your.private.git/.insteadOf https://your.private.git/`

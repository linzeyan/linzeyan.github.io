---
title: "Golang os/exec usage (notes)"
date: 2021-11-12T11:34:30+08:00
menu:
  sidebar:
    name: "Golang os/exec usage (notes)"
    identifier: go-golang-cmd-ex-exec-usage-note
    weight: 10
tags: ["Links", "Go"]
categories: ["Links", "Go"]
hero: images/hero/go.svg
---

- [Golang os/exec usage (notes)](https://124.244.86.40/wordpress/2020/10/25/golang-ex-exec-%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%EF%BC%88%E7%AD%86%E8%A8%98%EF%BC%89/)

#### Add extra environment variables before running a command

```go
cmd := exec.Command("programToExecute")
additionalEnv := "FOO=bar"
newEnv := append(os.Environ(), additionalEnv)
cmd.Env = newEnv
out, err := cmd.CombinedOutput()
if err != nil {
	log.Fatalf("cmd.Run() failed with %s\n", err)
}
fmt.Printf("%s", out)
```

#### Use os/exec with pipes or bash expressions on Linux

```go
rcmd := `iw dev | awk '$1=="Interface"{print $2}'`
cmd := exec.Command("bash", "-c", rcmd)
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

#### Use os/exec with batch expressions on Windows

```go
cmd := exec.Command("cmd", "/c", "ffmpeg -i myfile.mp4 myfile.mp3 && del myfile.mp4")
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

#### Fix local language issues in Windows CMD with os/exec

```go
cmd := exec.Command("cmd", "/c", "chcp 65001 && netsh WLAN show drivers")
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

When using this method, remember to remove the first line of output (the chcp response) before further processing.

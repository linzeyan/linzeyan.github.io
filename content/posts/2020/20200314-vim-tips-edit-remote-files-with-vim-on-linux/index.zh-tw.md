---
title: "Vim 小技巧 - 在 Linux 上用 Vim 編輯遠端檔案"
date: 2020-03-14T15:43:38+08:00
menu:
  sidebar:
    name: "Vim 小技巧 - 在 Linux 上用 Vim 編輯遠端檔案"
    identifier: linux-vim-tips-edit-remote-files-with-vim-on-linux
    weight: 10
tags: ["Links", "Vim"]
categories: ["Links", "Vim"]
hero: images/hero/kubernetes.png
---

- [Vim 小技巧 - 在 Linux 上用 Vim 編輯遠端檔案](https://www.ostechnix.com/vim-tips-edit-remote-files-with-vim-on-linux/)

#### 在 Linux 上用 Vim 編輯遠端檔案

```shell
$ vim scp://sk@192.168.225.22/info.txt
```

1. `user@remotesystem:port`（例如 `sk@192.168.225.22`）

2. 單斜線 (`/`) - 若要編輯位於遠端系統 $HOME 目錄的檔案，需要在遠端系統的 IP 或主機名後加上一個斜線，用來分隔檔案路徑。

3. 雙斜線 (`//`) - 若要指定檔案完整路徑，必須使用雙斜線。例如，你要編輯遠端系統 /home/sk/Documents/ 目錄下的 info.txt，命令會是：`vim scp://sk@192.168.225.22//home/sk/Documents/info.txt`

4. 如果沒有 ssh/scp 權限，可以改用其他協定，例如 `ftp`：`vim ftp://user@remotesystem/path/to/file`

#### 在 Vim 工作階段內編輯遠端檔案

`:e scp://sk@192.168.225.22/info.txt`

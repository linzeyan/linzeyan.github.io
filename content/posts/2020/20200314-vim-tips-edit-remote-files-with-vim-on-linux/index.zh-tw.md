---
title: "Vim Tips - Edit Remote Files With Vim On Linux"
date: 2020-03-14T15:43:38+08:00
menu:
  sidebar:
    name: "Vim Tips - Edit Remote Files With Vim On Linux"
    identifier: linux-vim-tips-edit-remote-files-with-vim-on-linux
    weight: 10
tags: ["URL", "Vim"]
categories: ["URL", "Vim"]
hero: images/hero/kubernetes.png
---

- [Vim Tips - Edit Remote Files With Vim On Linux](https://www.ostechnix.com/vim-tips-edit-remote-files-with-vim-on-linux/)

#### Edit remote files with Vim on Linux

```shell
$ vim scp://sk@192.168.225.22/info.txt
```

1. `user@remotesystem:port` (E.g. `sk@192.168.225.22`)

2. Single slash (`/`) - If you want to edit a file that is stored in the $HOME directory of a remote system, you must use a trailing slash to separate remote system's IP address or hostname from the file path.

3. Double slashes (`//`) - To specify full path of a file, you must use double slashes. For example, let us say you are editing a file named info.txt that is located in /home/sk/Documents/ directory of your remote system. In this case, the command would be: `vim scp://sk@192.168.225.22//home/sk/Documents/info.txt`

4. If you don't have ssh/scp access, you can use other protocols, for example `ftp`. `vim ftp://user@remotesystem/path/to/file`

#### Edit remote files within Vim session

`:e scp://sk@192.168.225.22/info.txt`

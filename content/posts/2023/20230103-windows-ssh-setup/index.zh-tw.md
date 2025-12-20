---
title: "Windows SSH setup"
date: 2023-01-03T12:36:00+08:00
menu:
  sidebar:
    name: "Windows SSH setup"
    identifier: ansible-windows-ssh-setup
    weight: 10
tags: ["URL", "Ansible", "Windows", "SSH"]
categories: ["URL", "Ansible", "Windows", "SSH"]
hero: images/hero/ansible.png
---

- [Windows SSH setup](https://ansible.cloudns.pro/post/windows-ssh-setup/)
- [Install OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)

1. 預設的 shell 是使用 cmd，照文件說，若需要修改，是要改 ansible_shell_type 變數，這應該是要在 inventory 主機裡加入主機變數：ansible_shell_type，變數內容可以是 cmd 或 powershell。
2. inventory 主機裡要加入 ansible_connection 主機變數，告知要使用 ssh 連線。(`192.168.192.11 ansible_user=Administrator ansible_connection=ssh ansible_shell_type=cmd
`)
3. 可能會需要在 ansible.cfg 裡加上 remote_tmp 設定，指定為 C:\TEMP
4. Playbook 裡可以使用 `win_` 開頭的模組，或是使用 raw 模組

---
title: "Windows SSH Setup"
date: 2023-01-03T12:36:00+08:00
menu:
  sidebar:
    name: "Windows SSH Setup"
    identifier: ansible-windows-ssh-setup
    weight: 10
tags: ["Links", "Ansible", "Windows", "SSH"]
categories: ["Links", "Ansible", "Windows", "SSH"]
hero: images/hero/ansible.png
---

- [Windows SSH Setup](https://ansible.cloudns.pro/post/windows-ssh-setup/)
- [Install OpenSSH for Windows](https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)

1. The default shell is cmd. The docs say to change the ansible_shell_type variable if needed. This should be set as a host variable in inventory: ansible_shell_type, with value cmd or powershell.
2. Add the ansible_connection host variable in inventory to indicate SSH connections. (`192.168.192.11 ansible_user=Administrator ansible_connection=ssh ansible_shell_type=cmd
`)
3. You may need to add remote_tmp in ansible.cfg and set it to C:\TEMP.
4. In playbooks, use modules prefixed with `win_`, or use the raw module.

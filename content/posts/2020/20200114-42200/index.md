---
title: "Cannot set command timeout per task with network_cli"
date: 2020-01-14T16:34:03+08:00
menu:
  sidebar:
    name: "Cannot set command timeout per task with network_cli"
    identifier: ansible-cannot-set-command-timeout-per-task-with-network_cli
    weight: 10
tags: ["URL", "Ansible"]
categories: ["URL", "Ansible"]
hero: images/hero/ansible.png
---

- [Cannot set command timeout per task with network_cli](https://github.com/ansible/ansible/issues/42200)
- [Ansible 的委托 并发和任务超时](https://www.cnblogs.com/v394435982/p/5180933.html)

```yaml
- name: run command
  ios_command:
    commands:
      - show version
  vars:
    ansible_command_timeout: 40
```

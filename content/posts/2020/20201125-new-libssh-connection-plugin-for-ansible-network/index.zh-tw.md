---
title: "Ansible Network 的新 LibSSH 連線外掛取代 Paramiko，並支援 FIPS 模式"
date: 2020-11-25T21:09:50+08:00
menu:
  sidebar:
    name: "Ansible Network 的新 LibSSH 連線外掛取代 Paramiko，並支援 FIPS 模式"
    identifier: ansible-new-libssh-connection-plugin-for-ansible-network
    weight: 10
tags: ["Links", "Ansible", "SSH"]
categories: ["Links", "Ansible", "SSH"]
hero: images/hero/ansible.png
---

- [Ansible Network 的新 LibSSH 連線外掛取代 Paramiko，並支援 FIPS 模式](https://www.ansible.com/blog/new-libssh-connection-plugin-for-ansible-network)

##### 切換 Ansible Playbook 使用 LibSSH

```bash
# 安裝 LibSSH
pip install ansible-pylibssh
```

在 Ansible Playbook 中使用 LibSSH

方法 1. 在專案的 `ansible.cfg` 檔案中設定 `ssh_type` 參數使用 libssh

```toml
[persistent_connection]
ssh_type = libssh
```

方法 2: 設定 `ANSIBLE_NETWORK_CLI_SSH_TYPE` 環境變數

```bash
$ export ANSIBLE_NETWORK_CLI_SSH_TYPE=libssh
```

方法 3: 在 play 等級的 playbook 中設定 `ansible_network_cli_ssh_type` 為 libssh

##### 用來測試 libssh 設定的 Playbook

```yaml
- hosts: "changeme"
  gather_facts: no
  connection: ansible.netcommon.network_cli
  vars:
    ansible_network_os: cisco.ios.ios
    ansible_user: "changeme"
    ansible_password: "changeme"
    ansible_network_cli_ssh_type: libssh
  tasks:
    - name: run show version command
      ansible.netcommon.cli_command:
        command: show version

    - name: run show version command
      ansible.netcommon.cli_command:
        command: show interfaces
```

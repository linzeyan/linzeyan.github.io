---
title: "New LibSSH Connection Plugin for Ansible Network Replaces Paramiko, Adds FIPS Mode Enablement"
date: 2020-11-25T21:09:50+08:00
menu:
  sidebar:
    name: "New LibSSH Connection Plugin for Ansible Network Replaces Paramiko, Adds FIPS Mode Enablement"
    identifier: ansible-new-libssh-connection-plugin-for-ansible-network
    weight: 10
tags: ["URL", "Ansible", "SSH"]
categories: ["URL", "Ansible", "SSH"]
hero: images/hero/ansible.png
---

- [New LibSSH Connection Plugin for Ansible Network Replaces Paramiko, Adds FIPS Mode Enablement](https://www.ansible.com/blog/new-libssh-connection-plugin-for-ansible-network)

##### Switching Ansible Playbooks to use LibSSH

```bash
# Installing LibSSH
pip install ansible-pylibssh
```

Using LibSSH in Ansible Playbooks

Method 1. The `ssh_type` configuration parameter can be set to use libssh in the active `ansible.cfg` file of your project

```toml
[persistent_connection]
ssh_type = libssh
```

Method 2: Set the `ANSIBLE_NETWORK_CLI_SSH_TYPE` environment variable

```bash
$ export ANSIBLE_NETWORK_CLI_SSH_TYPE=libssh
```

Method 3: Set the `ansible_network_cli_ssh_type` parameter to libssh within your playbook at the play level

##### Playbook to test libssh configuration settings

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

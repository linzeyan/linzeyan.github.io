---
title: "Ansible 簡介"
date: 2020-09-26T16:57:21+08:00
description: 分享 Ansible 概念
menu:
  sidebar:
    name: Ansible
    identifier: ansible
    weight: 10
tags: ["Ansible", "introduction", "slides"]
categories: ["Ansible"]
---

# 認識 Ansible

## 大綱

-  [簡介](#簡介)
-  [安裝](#安裝)
-  [常用模組](#常用模組)
-  [資料夾結構](#資料夾結構)
-  [結語](#結語)

---

### 簡介

* 安裝部署工具、設定管理工具等

* 同類型工具：Chef、Puppet、SaltStack

* 不需要 Agent、透過 ssh

* Linux 有 python 即可 ( ssh port )

* Win 啟用 winrm 即可 ( 5986 port )
  * https://docs.ansible.com/ansible/latest/user_guide/windows_winrm.html#inventory-options

* 資料夾結構簡單易懂、官方文件豐富易懂、模組多支援設備多、易撰寫


![](./pics/20200926_ansible.pics/20200926_ansible0.png)

![](./pics/20200926_ansible.pics/20200926_ansible1.png)

---

### 安裝

- pip install ansible
  - pip3 install ansible

- yum install ansible

- apt-get install ansible

- apk add ansible

![](pics/20200926_ansible.pics/20200926_ansible2.png)

---

### 常用模組

[ping](#常用模組-ping)

[shell / command](#常用模組-shell-command)

[file](#常用模組-file)

[yum](#常用模組-yum)

[systemd / service](#常用模組-systemd-service)

[template / copy](#常用模組-template-copy)

[debug](#常用模組-debug)

---

#### 常用模組 - ping

![](pics/20200926_ansible.pics/20200926_ansible3.png)

---

#### 常用模組 - shell / command

![](pics/20200926_ansible.pics/20200926_ansible4.png)

![](pics/20200926_ansible.pics/20200926_ansible5.png)

---

#### 常用模組 - file

![](pics/20200926_ansible.pics/20200926_ansible6.png)

---

#### 常用模組 - yum

![](pics/20200926_ansible.pics/20200926_ansible7.png)

---

#### 常用模組 - systemd / service

![](pics/20200926_ansible.pics/20200926_ansible8.png)

![](pics/20200926_ansible.pics/20200926_ansible9.png)

---

#### 常用模組 - template / copy

![](pics/20200926_ansible.pics/20200926_ansible10.png)

![](pics/20200926_ansible.pics/20200926_ansible11.png)

![](pics/20200926_ansible.pics/20200926_ansible12.png)

---

#### 常用模組 - debug / register

![](pics/20200926_ansible.pics/20200926_ansible13.png)

![](pics/20200926_ansible.pics/20200926_ansible14.png)

![](pics/20200926_ansible.pics/20200926_ansible15.png)

![](pics/20200926_ansible.pics/20200926_ansible16.png)

---

### 資料夾結構

![](pics/20200926_ansible.pics/20200926_ansible17.png)

![](pics/20200926_ansible.pics/20200926_ansible18.png)

![](pics/20200926_ansible.pics/20200926_ansible19.png)

---

### 結語

* 選擇適合的
  * ansible ad-hoc
    * `ansible gitlab -m ping`
    * `ansible gitlab -m shell -a 'rm -rf /'`
  * playbook
  * role
  * collection
  * shell script
  * python script
  * others

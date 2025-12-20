---
title: "將 List 轉置為 dict 的 list"
date: 2022-03-09T11:26:23+08:00
menu:
  sidebar:
    name: "將 List 轉置為 dict 的 list"
    identifier: ansible-how-to-transform-list-to-object-list
    weight: 10
tags: ["URL", "Ansible"]
categories: ["URL", "Ansible"]
hero: images/hero/ansible.png
---

- [將 List 轉置為 dict 的 list](https://ansible.cloudns.pro/post/how-to-transform-list-to-object-list/)

##### list

```yaml
my_users:
  - aaa
  - bbb
  - ccc
```

##### dict

```yaml
my_users:
  - Name: aaa
  - Name: bbb
  - Name: ccc
```

##### playbook

```yaml
- name: Transform data
  vars:
    orig_users:
      - aaa
      - bbb
      - ccc
    my_users: []
  set_fact:
    my_users: "{{ my_users + [{} | combine({'Name': item})] }}"
  loop: "{{ orig_users }}"
```

說明如下：

1. 利用 combine 這個 filter 來組出 dict
2. 利用 loop 去 iterate orig_users
3. 用 my_users + [{} | combine({'Name': item})] 來做 List append```

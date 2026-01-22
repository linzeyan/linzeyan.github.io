---
title: "Convert a List to a List of Dicts"
date: 2022-03-09T11:26:23+08:00
menu:
  sidebar:
    name: "Convert a List to a List of Dicts"
    identifier: ansible-how-to-transform-list-to-object-list
    weight: 10
tags: ["Links", "Ansible"]
categories: ["Links", "Ansible"]
hero: images/hero/ansible.png
---

- [Convert a List to a List of Dicts](https://ansible.cloudns.pro/post/how-to-transform-list-to-object-list/)

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

Explanation:

1. Use the combine filter to build a dict
2. Use loop to iterate orig_users
3. Use my_users + [{} | combine({'Name': item})] to append to the list```

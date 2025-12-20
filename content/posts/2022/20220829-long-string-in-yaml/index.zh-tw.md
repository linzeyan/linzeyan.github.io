---
title: "YAML 裡的字串很長該怎麼做？"
date: 2022-08-29T15:01:40+08:00
menu:
  sidebar:
    name: "YAML 裡的字串很長該怎麼做？"
    identifier: ansible-long-string-in-yaml
    weight: 10
tags: ["URL", "Ansible", "YAML"]
categories: ["URL", "Ansible", "YAML"]
hero: images/hero/ansible.png
---

- [YAML 裡的字串很長該怎麼做？](https://ansible.cloudns.pro/post/long-string-in-yaml/)

在 YAML 裡已經有規範此部份，在這種情況有四種方法可以幫助我們：

- `|`: 其下內容的換行，就是換行，最後一行會有換行。
- `>`: 其下內容的換行，不會是換行，會變為一個很長的字串，最後會有換行。
- `|-`: 其下內容的換行，就是換行，但最後一行不會有換行。
- `>-`: 其下內容的換常，不會是換行，最後一行也不會有換行。

簡單的說，`>` 跟 `>-` 可以增加 YAML 的可讀性，又不會有多餘的換行符號。而 `|` 跟 `|-` 則可以讓字串跟定義的一致，在 YAML 裡看到換行，那字串裡就會有換行符號。

```yaml
---
- name: Test long string
  hosts: all

  vars:
    s1: "hello"
    s2: |
      s2
      this is my very very very
      long string
      line1
      line2
      line3
    s3: >
      s3
      this is my very very very
      long string
      line1
      line2
      line3
    s4: |-
      s4
      this is my very very very
      long string
      line1
      line2
      line3
    s5: >-
      s5
      this is my very very very
      long string
      line1
      line2
      line3

  tasks:
    - name: s1
      copy:
        content: "{{ s1 }}"
        dest: "/tmp/s1.txt"
    # hello%

    - name: s2
      copy:
        content: "{{ s2 }}"
        dest: "/tmp/s2.txt"
    # s2
    # this is my very very very
    # long string
    # line1
    # line2
    # line3

    - name: s3
      copy:
        content: "{{ s3 }}"
        dest: "/tmp/s3.txt"
    # s3 this is my very very very long string line1 line2 line3

    - name: s4
      copy:
        content: "{{ s4 }}"
        dest: "/tmp/s4.txt"
    # s4
    # this is my very very very
    # long string
    # line1
    # line2
    # line3%

    - name: s5
      copy:
        content: "{{ s5 }}"
        dest: "/tmp/s5.txt"
    # s5 this is my very very very long string line1 line2 line3%
```

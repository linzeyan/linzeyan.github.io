---
title: "What to Do With Long Strings in YAML?"
date: 2022-08-29T15:01:40+08:00
menu:
  sidebar:
    name: "What to Do With Long Strings in YAML?"
    identifier: ansible-long-string-in-yaml
    weight: 10
tags: ["Links", "Ansible", "YAML"]
categories: ["Links", "Ansible", "YAML"]
hero: images/hero/ansible.png
---

- [What to Do With Long Strings in YAML?](https://ansible.cloudns.pro/post/long-string-in-yaml/)

YAML already defines this. In this case, there are four methods:

- `|`: Newlines under it are preserved as newlines, and the last line ends with a newline.
- `>`: Newlines under it are folded into spaces, forming a long string, and the last line ends with a newline.
- `|-`: Newlines under it are preserved, but the last line does not end with a newline.
- `>-`: Newlines under it are folded into spaces, and the last line does not end with a newline.

In short, `>` and `>-` improve YAML readability without adding extra newline characters. `|` and `|-` keep the string exactly as defined: if you see a newline in YAML, the string contains a newline.

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

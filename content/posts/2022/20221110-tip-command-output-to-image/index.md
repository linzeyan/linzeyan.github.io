---
title: "將指令輸出轉為圖片"
date: 2022-11-10T16:13:04+08:00
menu:
  sidebar:
    name: "將指令輸出轉為圖片"
    identifier: ansible-tip-command-output-to-image
    weight: 10
tags: ["URL", "Ansible"]
categories: ["URL", "Ansible"]
hero: images/hero/ansible.png
---

- [將指令輸出轉為圖片](https://ansible.cloudns.pro/post/tips/tip-command-output-to-image/)

```yaml
---
- name: Capture command output and convert to image
  hosts: all

  tasks:
    - name: Display content of /etc/redhat-release
      shell: cat /etc/redhat-release
      register: redhat_release_result

    - name: hostname
      shell: hostname
      register: hostname_result

    # 可以使用 ImageMagick 來轉換文字為圖片
    - name: Convert command output as image
      shell: echo -e "{{ hostname_result.stdout }}\n{{ redhat_release_result.stdout }}" | convert label:@- {{ hostname_result.stdout }}.png
      delegate_to: localhost
```

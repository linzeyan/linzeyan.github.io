---
title: "Convert Command Output to an Image"
date: 2022-11-10T16:13:04+08:00
menu:
  sidebar:
    name: "Convert Command Output to an Image"
    identifier: ansible-tip-command-output-to-image
    weight: 10
tags: ["Links", "Ansible"]
categories: ["Links", "Ansible"]
hero: images/hero/ansible.png
---

- [Convert Command Output to an Image](https://ansible.cloudns.pro/post/tips/tip-command-output-to-image/)

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

    # You can use ImageMagick to convert text to an image
    - name: Convert command output as image
      shell: echo -e "{{ hostname_result.stdout }}\n{{ redhat_release_result.stdout }}" | convert label:@- {{ hostname_result.stdout }}.png
      delegate_to: localhost
```

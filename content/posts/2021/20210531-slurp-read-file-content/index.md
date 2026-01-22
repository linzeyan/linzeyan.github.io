---
title: "ansible.builtin.slurp - read file content"
date: 2021-05-31T17:15:04+08:00
menu:
  sidebar:
    name: "ansible.builtin.slurp - read file content"
    identifier: ansible-module-slurp-read-file-content
    weight: 10
tags: ["Links", "Ansible"]
categories: ["Links", "Ansible"]
hero: images/hero/ansible.png
---

- [ansible.builtin.slurp - read file content](https://ansible.cloudns.pro/post/slurp-read-file-content/)

```yaml
---
- name: Use HTTP POST to upload file
  hosts: all

  tasks:
    - name: Read binary file content
      slurp:
        path: "/bin/ls"
      register: bin_file

    - name: Send HTTP POST Request
      uri:
        url: "https://your_server/upload.php"
        headers:
          Accept: "application/json"
          Content-Type: "application/octet-stream"
        method: POST
        validate_certs: false
        body: "{{ bin_file.content }}"
        status_code:
          - 200
          - 201
      register: upload_result

    - name: Display upload_result
      debug:
        var: upload_result
```

Using slurp avoids the limitations of lookup('file').

- You can read files on managed hosts, or use delegate_to: localhost to read files on the controller.
- You can read binary files for further processing, such as base64 encoding.

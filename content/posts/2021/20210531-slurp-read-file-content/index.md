---
title: "ansible.builtin.slurp - 讀取檔案內容"
date: 2021-05-31T17:15:04+08:00
menu:
  sidebar:
    name: "ansible.builtin.slurp - 讀取檔案內容"
    identifier: ansible-module-slurp-read-file-content
    weight: 10
tags: ["URL", "Ansible"]
categories: ["URL", "Ansible"]
hero: images/hero/ansible.png
---

- [ansible.builtin.slurp - 讀取檔案內容](https://ansible.cloudns.pro/post/slurp-read-file-content/)

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

使用 slurp，就可以避掉 lookup('file') 的限制。

- 可以讀取受控端主機上的檔案，也可以利用 delegate_to: localhost 來讀取主控端主機上的檔案。
- 可以讀取二進位檔案來做進一步處理，例如做 base64 編碼

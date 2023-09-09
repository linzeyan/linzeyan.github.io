---
title: Ansible Command
weight: 100
menu:
  notes:
    name: ansible
    identifier: notes-ansible-lookup
    parent: notes-bash
    weight: 10
---

{{< note title="Lookup" >}}

```bash
# List all plugins
ansible-doc -t lookup -l

# Use `ansible-doc -t lookup <plugin>` to see detail
ansible-doc -t lookup ping
```

{{< /note >}}

{{< note title="winrm" >}}

##### console output

在 hyper-v 那台機器 Enable Winrm 之後 一直出現下面的錯誤。
在 group 加上一行即可
`ansible_winrm_transport=ntlm`

```json
hyper-v01 | UNREACHABLE! => {
    "changed": false,
    "msg": "ssl: the specified credentials were rejected by the server",
    "unreachable": true

}
```

##### /etc/ansible/hosts

```ini
ansible_user=administrator
ansible_password=password
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
ansible_winrm_transport=ntlm
```

{{< /note >}}

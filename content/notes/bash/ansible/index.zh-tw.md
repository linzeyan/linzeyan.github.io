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

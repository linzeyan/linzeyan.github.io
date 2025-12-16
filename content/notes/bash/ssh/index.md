---
title: SSH Command
weight: 100
menu:
  notes:
    name: ssh
    identifier: notes-bash-ssh-keygen
    parent: notes-bash
    weight: 10
---

{{< note title="Generate ssh key" >}}

```bash
# RSA
ssh-keygen -m PEM -t rsa -b 4096 -C "zeyanlin@outlook.com"

# ED25519
ssh-keygen -t ed25519 -C "dev" -f ~/.ssh/ed25519
```

{{< /note >}}

{{< note title="ssh config" >}}

```sshconfig
Host private.example.com
  ProxyCommand /usr/local/bin/cloudflared access ssh --hostname %h
```

{{< /note >}}

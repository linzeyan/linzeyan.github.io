---
title: "SSH certificate login guide"
date: 2020-07-08T13:39:48+08:00
menu:
  sidebar:
    name: "SSH certificate login guide"
    identifier: linux-ssh-login-certificate-introduce
    weight: 10
tags: ["Links", "SSH", "Linux"]
categories: ["Links", "SSH", "Linux"]
hero: images/hero/linux.png
---

- [SSH certificate login guide](https://www.ruanyifeng.com/blog/2020/07/ssh-certificate.html)

### Certificate login flow

Before using SSH certificate login, you need to generate certificates. The steps are:

1. The user and the server both send their public keys to the CA.
2. The CA uses the server public key to generate a server certificate and sends it to the server.
3. The CA uses the user public key to generate a user certificate and sends it to the user.

Once certificates are in place, the user can log in. SSH handles the whole process automatically.

1. When the user logs in, SSH automatically sends the user certificate to the server.
2. The server checks whether the user certificate is valid and issued by a trusted CA.
3. SSH automatically sends the server certificate to the user.
4. The user checks whether the server certificate is valid and issued by a trusted CA.
5. The connection is established and the server allows the user to log in.

### Generate CA keys

Although a CA can use the same key pair to sign user and server certificates, for security and flexibility it is better to use different keys. So the CA needs at least two key pairs: one for user certificates (say `user_ca`) and one for server certificates (say `host_ca`).

```shell
# Generate the CA key for signing user certificates.
# This creates a key pair in ~/.ssh: user_ca (private key) and user_ca.pub (public key).
# Parameter notes:
# -t rsa: key algorithm.
# -b 4096: key size. You can use a smaller value for lower security needs, but not less than 1024.
# -f ~/.ssh/user_ca: output file path.
# -C user_ca: key comment.
$ ssh-keygen -t rsa -b 4096 -f ~/.ssh/user_ca -C user_ca


# Generate the CA key for signing server certificates.
# This creates a key pair in ~/.ssh: host_ca (private key) and host_ca.pub (public key).
# Now ~/.ssh should have at least four keys:
# - ~/.ssh/user_ca
# - ~/.ssh/user_ca.pub
# - ~/.ssh/host_ca
# - ~/.ssh/host_ca.pub
$ ssh-keygen -t rsa -b 4096 -f host_ca -C host_ca
```

#### Install CA public key on server

```shell
# To let the server trust user certificates, copy the CA public key user_ca.pub to the server.
$ scp ~/.ssh/user_ca.pub root@host.example.com:/etc/ssh/
```

##### Then add the following line to `/etc/ssh/sshd_config`

```
TrustedUserCAKeys /etc/ssh/user_ca.pub
```

This adds `user_ca.pub` to `/etc/ssh/sshd_config`, which means all server accounts will trust user certificates signed by `user_ca`.

##### Another option

Add `user_ca.pub` to a specific user's `~/.ssh/authorized_keys` so only that account trusts certificates signed by `user_ca`. Open `~/.ssh/authorized_keys` and append a line starting with `@cert-authority principals="..."`, followed by the content of `user_ca.pub`.

```
@cert-authority principals="user" ssh-rsa AAAAB3Nz...XNRM1EX2gQ==
```

Here, `principals="user"` is the server account name the user will log in as, usually the account that owns the `authorized_keys` file.

```shell
$ sudo systemctl restart sshd
```

### CA signs server certificates

> To sign a certificate, the CA needs the server public key in addition to the CA key. Usually the SSH server (sshd) already generates `/etc/ssh/ssh_host_rsa_key` during installation. If not, you can create it:
>
> `$ sudo ssh-keygen -f /etc/ssh/ssh_host_rsa_key -b 4096 -t rsa`
>
> This creates `ssh_host_rsa_key` (private key) and `ssh_host_rsa_key.pub` (public key) in `/etc/ssh`. Then copy or upload `ssh_host_rsa_key.pub` to the CA server.

```shell
# After uploading, the CA can use host_ca to sign ssh_host_rsa_key.pub.
# This command generates the server certificate ssh_host_rsa_key-cert.pub (public key with -cert suffix).
# Parameter notes:
# -s: CA key for signing.
# -I: identity string (comment) used for identification and future revocation.
# -h: server certificate (not a user certificate).
# -n host.example.com: server domain name. Use commas for multiple domains.
#   SSH uses this value to choose the correct certificate for the server.
# -V +52w: validity period. Default is forever. Use a shorter period, no more than 52 weeks.
# ssh_host_rsa_key.pub: server public key.
$ ssh-keygen -s host_ca -I host.example.com -h -n host.example.com -V +52w ssh_host_rsa_key.pub
$ chmod 600 ssh_host_rsa_key-cert.pub
```

#### Install certificate on server

```shell
# After the CA generates ssh_host_rsa_key-cert.pub, copy it back to the server.
$ scp ~/.ssh/ssh_host_rsa_key-cert.pub root@host.example.com:/etc/ssh/
```

Then add the following line to `/etc/ssh/sshd_config` to tell sshd which server certificate to use:

```
HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
```

```shell
$ sudo systemctl restart sshd
```

### CA signs user certificates

```shell
# Upload or copy user_key.pub to the CA server. Then use user_ca to sign user_key.pub.
# This generates the user certificate user_key-cert.pub (public key with -cert suffix).
# Parameter notes:
# -s: CA key for signing.
# -I: identity string (comment) for identification and future revocation.
# -n user: username. Use commas for multiple usernames.
#   SSH uses this value to choose the correct certificate for the user.
# -V +1d: validity period (1 day here). Default is forever. Shorter periods are safer.
# user_key.pub: user public key.
$ ssh-keygen -s user_ca -I user@example.com -n user -V +1d user_key.pub
$ chmod 600 user_key-cert.pub
```

### Install certificate on client

Installing the user certificate on the client is straightforward: copy `user_key-cert.pub` from the CA and place it in the same directory as the user's key `user_key`.

#### Install CA public key on client

To trust server certificates, add the CA public key `host_ca.pub` to `/etc/ssh/ssh_known_hosts` (system-wide) or `~/.ssh/known_hosts` (per-user).

Open ssh_known_hosts or known_hosts, append a line starting with `@cert-authority *.example.com`, and then paste the content of host_ca.pub:

```
@cert-authority *.example.com ssh-rsa AAAAB3Nz...XNRM1EX2gQ==
```

Here `*.example.com` is a domain pattern. If there is no domain restriction, use `*`. You can use multiple patterns separated by commas. If there is no domain, you can use hostnames (e.g., host1,host2,host3) or IPs (e.g., 11.12.13.14,21.22.23.24).

### Revoke certificates

- To revoke a server certificate, update or remove the corresponding `@cert-authority` line in known_hosts.
- To revoke a user certificate, create `/etc/ssh/revoked_keys` on the server and add this line to `sshd_config`:
  - `RevokedKeys /etc/ssh/revoked_keys`
  - `$ ssh-keygen -kf /etc/ssh/revoked_keys -z 1 ~/.ssh/user1_key.pub`
    - In this command, `-z` specifies which line in revoked_keys stores the user public key. This example uses line 1.

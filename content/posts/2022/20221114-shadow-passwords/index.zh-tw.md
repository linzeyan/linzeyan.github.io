---
title: "/etc/shadow and Creating yescrypt, MD5, SHA-256, and SHA-512 Password Hashes"
date: 2022-11-14T12:55:39+08:00
menu:
  sidebar:
    name: "/etc/shadow and Creating yescrypt, MD5, SHA-256, and SHA-512 Password Hashes"
    identifier: linux-shadow-passwords-hashes
    weight: 10
tags: ["URL", "Linux", "SHELL", "command line"]
categories: ["URL", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [/etc/shadow and Creating yescrypt, MD5, SHA-256, and SHA-512 Password Hashes](https://www.baeldung.com/linux/shadow-passwords)

##### chage and Password Aging

```bash
chage --list root
Last password change                                    : Oct 01, 2022
Password expires                                        : never
Password inactive                                       : never
Account expires                                         : never
Minimum number of days between password change          : 0
Maximum number of days between password change          : 99999
Number of days of warning before password expires       : 7
```

Consequently, we can change any field via its associated flag:

- `-d` or `--lastday` for the last change date
- `-m` or `--mindays` for the days between password changes
- `-M` or `--maxdays` for the maximum password validity
- `-W` or `--warndays` for the warning period
- `-I` or `--inactive` for the inactivity period
- `-E` or `--expiredate` for the expiration period

##### chpasswd and Passwords

`echo 'user1:PASSWORD' | chpasswd --crypt-method SHA512`

##### crypt() and Encryption Algorithms

Essentially, the initial characters of the password field value in /etc/shadow identify the encryption algorithm:

- `$1$` is Message Digest 5 (MD5)
- `$2a$` is blowfish
- `$5$` is 256-bit Secure Hash Algorithm (SHA-256)
- `$6$` is 512-bit Secure Hash Algorithm (SHA-512)
- `$y$` (or `$7$`) is yescrypt
- noneof the above means DES

##### Generate /etc/shadow Passwords

OpenSSL support several types of hashing:

- `-crypt` for the standard UNIX crypt, i.e., DES (default)
- `-apr1` for the Apache-specific MD5 variant
- `-1` for MD5
- `-5` for SHA-256
- `-6` for SHA-512

```bash
# OpenSSL
openssl passwd -6 PASSWORD
$1$SALT$YQNBYRN9kIvLkQIp4SpsO0


# Perl
perl -e 'print crypt "PASSWORD", "\$6\$SALT\$"'
$6$SALT$io0TPmhM8ythCm7Idt0AfYvTuFCLyA1CMVmeT3EUqarf2NQcTuLKEgP9.4Q8fgClzP7OCnyOY1wo1xDw0jtyH1


# Python
python3 -c 'import crypt; print(crypt.crypt("PASSWORD", "$6$SALT"))'
$6$SALT$io0TPmhM8ythCm7Idt0AfYvTuFCLyA1CMVmeT3EUqarf2NQcTuLKEgP9.4Q8fgClzP7OCnyOY1wo1xDw0jtyH1
python3 -c 'import crypt,getpass; print(crypt.crypt("PASSWORD",crypt.mksalt(crypt.METHOD_SHA512)))'
python3 -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(),crypt.mksalt(crypt.METHOD_SHA512)))'


# Ruby
ruby -e 'puts "PASSWORD".crypt("$6$SALT")'
$6$SALT$io0TPmhM8ythCm7Idt0AfYvTuFCLyA1CMVmeT3EUqarf2NQcTuLKEgP9.4Q8fgClzP7OCnyOY1wo1xDw0jtyH1
# we can also use a random salt and stdin for the password entry
ruby -e 'require "io/console"; puts IO::console.getpass.crypt("$6$" + rand(36 ** 8).to_s(36))'
```

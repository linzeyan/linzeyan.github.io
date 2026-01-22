---
title: "/etc/shadow 與建立 yescrypt、MD5、SHA-256、SHA-512 密碼雜湊"
date: 2022-11-14T12:55:39+08:00
menu:
  sidebar:
    name: "/etc/shadow 與建立 yescrypt、MD5、SHA-256、SHA-512 密碼雜湊"
    identifier: linux-shadow-passwords-hashes
    weight: 10
tags: ["Links", "Linux", "SHELL", "command line"]
categories: ["Links", "Linux", "SHELL", "command line"]
hero: images/hero/linux.png
---

- [/etc/shadow 與建立 yescrypt、MD5、SHA-256、SHA-512 密碼雜湊](https://www.baeldung.com/linux/shadow-passwords)

##### chage 與密碼期限

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

因此，我們可以用對應的旗標修改各欄位：

- `-d` 或 `--lastday`：最後變更日期
- `-m` 或 `--mindays`：變更密碼最少間隔天數
- `-M` 或 `--maxdays`：密碼最大有效天數
- `-W` 或 `--warndays`：到期前警告天數
- `-I` 或 `--inactive`：密碼失效天數
- `-E` 或 `--expiredate`：帳號過期日期

##### chpasswd 與密碼

`echo 'user1:PASSWORD' | chpasswd --crypt-method SHA512`

##### crypt() 與加密演算法

基本上，/etc/shadow 密碼欄位的開頭字元可以辨識加密演算法：

- `$1$` 是 Message Digest 5（MD5）
- `$2a$` 是 blowfish
- `$5$` 是 256-bit Secure Hash Algorithm（SHA-256）
- `$6$` 是 512-bit Secure Hash Algorithm（SHA-512）
- `$y$`（或 `$7$`）是 yescrypt
- 以上皆非則表示 DES

##### 產生 /etc/shadow 密碼

OpenSSL 支援多種雜湊：

- `-crypt`：標準 UNIX crypt，也就是 DES（預設）
- `-apr1`：Apache 專用的 MD5 變體
- `-1`：MD5
- `-5`：SHA-256
- `-6`：SHA-512

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

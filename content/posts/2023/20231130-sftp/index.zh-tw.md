---
title: "Add SFTP user and share directory"
date: 2023-11-30T17:22:00+08:00
menu:
  sidebar:
    name: Add SFTP user and share directory
    identifier: sftp-ssh
    weight: 10
tags: ["SSH", "SFTP", "Linux"]
categories: ["SSH", "SFTP", "Linux"]
hero: images/hero/linux.png
---

# Add SFTP user and share directory

dev_test_user, qa_test_user 同權限
dev_user, qa_user 同權限

## 1. 建立共享資料夾(SFTP 使用的資料夾)

```bash
sudo mkdir -p /home/{test,prod}/{exchange,upload}
sudo mkdir -p /home/{test,prod}/exchange/success
sudo mkdir -p /home/{test,prod}/upload/backup
```

## 2. 建立使用者群組

```bash
sudo groupadd share01-test
sudo groupadd share01-prod
```

## 3. 創建 qa_test_user 使用者並設定 qa_test_user 使用者的群組為 share01-test

```bash
sudo useradd -m -G share01-test qa_test_user

# 設定 dev_test_user 使用者的群組為 share01-test
sudo usermod -G share01-test dev_test_user

# 設定密碼
sudo passwd qa_test_user
```

## 4. 創建 qa_user 使用者並設定 qa_user 使用者的群組為 share01-prod

```bash
sudo useradd -m -G share01-prod qa_user

# 設定 dev_user 使用者的群組為 share01-prod
sudo usermod -G share01-prod dev_user

# 設定密碼
sudo passwd qa_user
```

## 5. 設定權限

```bash
# 設定 /home/test 資料夾(含下級資料夾)的使用者為 qa_test_user，群組為 share01-test
sudo chown -R qa_test_user:share01-test test/

# 設定 /home/prod 資料夾(含下級資料夾)的使用者為 qa_user，群組為 share01-prod
sudo chown -R qa_user:share01-prod prod/

# SFTP 登入資料夾權限要給 root
sudo chown root:root /home/test
sudo chown root:root /home/prod
```

## 6. 設定 /etc/ssh/sshd_config

`/etc/ssh/sshd_config`

```ssh_config
# 在最底下增加設定
Match group share01-test
    ChrootDirectory /home/test
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp -d /upload

Match group share01-prod
    ChrootDirectory /home/prod
    X11Forwarding no
    AllowTcpForwarding no
    ForceCommand internal-sftp -d /upload
```

```bash
# 重新啟動 sshd 讓設定生效
sudo systemctl restart sshd.service
```

---
title: "在 Amazon EC2 上掛載 AWS S3 Bucket"
date: 2024-06-09T15:37:30+08:00
menu:
  sidebar:
    name: "在 Amazon EC2 上掛載 AWS S3 Bucket"
    identifier: aws-mount-aws-s3-bucket-on-amazon-ec2
    weight: 10
tags: ["Links", "AWS", "S3"]
categories: ["Links", "AWS", "S3"]
---

- [在 Amazon EC2 上掛載 AWS S3 Bucket](https://surajblog.medium.com/mount-aws-s3-bucket-on-amazon-ec2-9f18b48d4f04)

**_使用情境_**

- 資料備份與封存：有效率地從 S3 儲存與取回資料，用於可靠備份與長期封存。
- 大數據與分析：直接存取 S3 中的大型資料集，進行順暢的資料處理與分析。
- 網站代管與內容分發：使用 S3 提供靜態內容，以高效率地託管網站與媒體檔案。
- 日誌收集與分析：集中將日誌存放在 S3，方便分析與監控。
- 檔案分享與協作：多台 EC2 透過 S3 作為共享資料庫來分享與協作。

**_先決條件_**

- 一台執行 Linux 的 Amazon EC2 執行個體（Amazon Linux、Ubuntu、CentOS 等）。
- 已附加具備存取 S3 Bucket 權限的 IAM 角色。

```shell
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install s3fs -y

# 建立 S3 bucket 的掛載點目錄
sudo mkdir /mnt/s3-bucket

# 同步本機目錄與 S3 bucket 以檢查存取
cd /mnt/s3-bucket ;touch test1.txt test2.txt
aws s3 sync /mnt/s3-bucket s3://<your-s3-bucket-name>

# 將 S3 bucket 掛載成檔案系統
sudo s3fs <your-s3-bucket-name> /mnt/s3-bucket -o iam_role=<iam-role-name> -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 -o use_path_request_style -o url=https://s3-{{aws_region}}.amazonaws.com

```

##### 除錯問題

需要除錯時，可加上：

```shell
$ sudo s3fs <your-s3-bucket-name> /mnt/s3-bucket -o iam_role=<iam-role-name> -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 -o use_path_request_style -o url=https://s3-{{aws_region}}.amazonaws.com -o dbglevel=info -f -o curldbg
```

確認掛載狀態

```shell
df -h | grep s3fs

```

讓 S3 bucket 在重新開機後仍可持續掛載

`/etc/fstab`

```shell
s3fs#<your-s3-bucket-name> /mnt/s3-bucket fuse _netdev,iam_role=<iam-role-name>,allow_other 0 0
```

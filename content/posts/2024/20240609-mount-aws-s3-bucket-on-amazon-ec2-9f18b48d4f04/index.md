---
title: "Mount AWS S3 Bucket On Amazon EC2"
date: 2024-06-09T15:37:30+08:00
menu:
  sidebar:
    name: "Mount AWS S3 Bucket On Amazon EC2"
    identifier: aws-mount-aws-s3-bucket-on-amazon-ec2
    weight: 10
tags: ["URL", "AWS", "S3"]
categories: ["URL", "AWS", "S3"]
---

- [Mount AWS S3 Bucket On Amazon EC2](https://surajblog.medium.com/mount-aws-s3-bucket-on-amazon-ec2-9f18b48d4f04)

**_Use Cases_**

- Data Backup and Archiving: Efficiently store and retrieve data from S3 to perform reliable backups and long-term archiving.
- Big Data and Analytics: Directly access large datasets in S3 for seamless data processing and analytics.
- Web Hosting and Content Distribution: Serve static content from S3 to host websites and media files efficiently.
- Log Collection and Analysis: Centrally store logs in S3 for easy log analysis and monitoring.
- File Sharing and Collaboration: Share and collaborate on files among multiple EC2 instances using S3 as a shared data repository.

**_Prerequisites_**

- An Amazon EC2 instance running Linux (Amazon Linux, Ubuntu, CentOS, etc.).
- IAM role attached to the EC2 instance with appropriate permissions to access the S3 bucket.

```shell
sudo apt-get update -y
sudo apt-get install awscli -y
sudo apt-get install s3fs -y

# Create a mount point directory for the S3 bucke
sudo mkdir /mnt/s3-bucket

# sync the local directory with the S3 bucket to check the access
cd /mnt/s3-bucket ;touch test1.txt test2.txt
aws s3 sync /mnt/s3-bucket s3://<your-s3-bucket-name>

# mount the S3 bucket as a filesystem
sudo s3fs <your-s3-bucket-name> /mnt/s3-bucket -o iam_role=<iam-role-name> -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 -o use_path_request_style -o url=https://s3-{{aws_region}}.amazonaws.com

```

##### Debug issue

To debug at any point, add

```shell
$ sudo s3fs <your-s3-bucket-name> /mnt/s3-bucket -o iam_role=<iam-role-name> -o use_cache=/tmp -o allow_other -o uid=1001 -o mp_umask=002 -o multireq_max=5 -o use_path_request_style -o url=https://s3-{{aws_region}}.amazonaws.com -o dbglevel=info -f -o curldbg
```

Verify the mount status

```shell
df -h | grep s3fs

```

To make the S3 bucket mount persistent across reboots

`/etc/fstab`

```shell
s3fs#<your-s3-bucket-name> /mnt/s3-bucket fuse _netdev,iam_role=<iam-role-name>,allow_other 0 0
```

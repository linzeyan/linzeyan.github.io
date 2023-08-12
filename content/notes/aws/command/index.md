---
title: AWS Command
weight: 100
menu:
  notes:
    name: command
    identifier: notes-aws-command
    parent: notes-aws
    weight: 10
---

{{< note title="ECR" >}}

```bash
# Get password and login to 12345.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr get-login-password | docker login --username AWS --password-stdin 12345.dkr.ecr.ap-northeast-1.amazonaws.com
```

{{< /note >}}

{{< note title="S3" >}}

```bash
# Sync local local_dir to S3
aws s3 sync local_dir s3://bucket_name --acl public-read --delete
```

{{< /note >}}

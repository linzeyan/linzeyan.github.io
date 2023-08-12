---
title: AWS Configure
weight: 100
menu:
  notes:
    name: configure
    identifier: notes-aws-configure
    parent: notes-aws
    weight: 10
---

{{< note title="CORS" >}}

```json
[
  {
    "AllowedHeaders": ["*"],
    "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
    "AllowedOrigins": ["*"],
    "ExposeHeaders": [
      "x-amz-server-side-encryption",
      "x-amz-request-id",
      "x-amz-id-2"
    ],
    "MaxAgeSeconds": 3000
  }
]
```

{{< /note >}}

{{< note title="ECR Lifecycle Policy" >}}

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep only the last 100 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 100
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

{{< /note >}}

{{< note title="ECR Lifecycle Policy1" >}}

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove images with certain tag",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["tag1", "tag2"],
        "countType": "imageCountMoreThan",
        "countNumber": 0
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

{{< /note >}}

{{< note title="ECR Lifecycle Policy2" >}}

```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Remove untagged images older than 14 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

{{< /note >}}

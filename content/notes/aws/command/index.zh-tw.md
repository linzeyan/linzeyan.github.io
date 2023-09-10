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

{{< note title="CloudFront" >}}

```bash
# list distributions
aws cloudfront list-distributions --query '*.Items[*].[Comment,Id,Aliases.Items[0],DefaultCacheBehavior.TargetOriginId]' --output table

# create invalidation
aws cloudfront create-invalidation --distribution-id  EATDVGD171BHDS1  --paths "/*"

## check cloudfornt log enable or not
for i in $(aws cloudfront list-distributions --output table --query 'DistributionList.Items[*].Id' --profile route53 | sed '1,3d;$d' | awk '{print $2}')
do
  result=$(aws cloudfront get-distribution --id ${i} --query 'Distribution.DistributionConfig.Logging' --profile route53 | jq .Enabled)
  if [[ "${result}" != "true" ]];then
    echo ${i}
  fi
done
```

{{< /note >}}

{{< note title="ECR" >}}

```bash
# Get password and login to 12345.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr get-login-password | docker login --username AWS --password-stdin 12345.dkr.ecr.ap-northeast-1.amazonaws.com
```

{{< /note >}}

{{< note title="S3" >}}

```bash
# Copy local file to S3
aws s3 cp ./pic.png s3://bucket_name/dir/

# Sync local local_dir to S3
aws s3 sync local_dir s3://bucket_name --exclude 'gameConfig.json' --acl public-read --delete
```

{{< /note >}}

{{< note title="snapshot" >}}

```bash
# list
aws ec2 describe-snapshots \
        --owner-ids self \
        --query "Snapshots[?(Tags[0].Value=='backend')].[SnapshotId,VolumeId]" \
        --region ap-northeast-1

# create
aws ec2 create-snapshot --volume-id vol-02468851c2bc3bc4b --description "gitlab-$(date +%F)" --region ap-northeast-1

# delete
aws ec2 delete-snapshot --snapshot-id snap-1234567890abcdef0 --region ap-northeast-1
```

{{< /note >}}

{{< note title="WAF" >}}

```bash
aws wafv2 create-web-acl \
  --name acl_name \
  --scope CLOUDFRONT \
  --default-action Allow={} \
  --visibility-config SampledRequestsEnabled=true,CloudWatchMetricsEnabled=true,MetricName=metric_acl_name \
  --rule
```

{{< /note >}}

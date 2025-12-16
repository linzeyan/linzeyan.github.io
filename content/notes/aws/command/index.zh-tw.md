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

{{< note title="EC2" >}}

```bash
# list
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[0].Value,InstanceId]' --output table --page-size 100
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

{{< note title="sns" >}}

```bash
region='ap-east-1'
account_id='888886666321'
topic='sa'

# create topic
aws sns create-topic --name ${topic}

# subscribe
aws sns subscribe --topic-arn arn:aws:sns:${region}:${account_id}:${topic} --protocol email --notification-endpoint ricky@gmail.com

# list
aws sns list-subscriptions-by-topic --topic-arn arn:aws:sns:${region}:${account_id}:${topic}

# create alarm
### metric-name
##CPUUtilization -->percent
##NetworkIn -->bytes
##NetworkOut -->bytes
for line in $(aws ec2 describe-instances --query 'Reservations[*].Instances[*].[Tags[0].Value,InstanceId]' --output table --page-size 100)
do
    ID=$(echo ${line}|awk -F ',' '{print $1}')
    VALUE=$(echo ${line}|awk -F ',' '{print $2}')
    aws cloudwatch put-metric-alarm \
        --alarm-name ${ID}_netout \
        --metric-name NetworkOut \
        --namespace AWS/EC2 \
        --statistic Average \
        --period 300 \
        --threshold 2560000 \
        --comparison-operator GreaterThanOrEqualToThreshold \
        --dimensions  "Name=InstanceId,Value=${VALUE}" \
        --evaluation-periods 3 \
        --alarm-actions arn:aws:sns:${region}:${account_id}:${topic}
        ##--unit Bytes
    echo "$ID done"
done
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

{{< note title="Mount S3 Bucket on EC2" >}}

references: [How to Mount S3 Bucket on Ubuntu 22.04 with S3FS Fuse](https://linuxbeast.com/blog/how-to-mount-s3-bucket-on-ubuntu-22-04-with-s3fs-fuse/)

```bash
# Installing s3fs-fuse
sudo apt-get update && sudo apt-get install s3fs

# Configuring AWS Credentials
echo ACCESS_KEY_ID:SECRET_ACCESS_KEY > ${HOME}/.passwd-s3fs
chmod 600 ${HOME}/.passwd-s3fs

# Mounting the S3 Bucket
s3fs mybucketname:/path/to/dir /path/to/local/mountpoint -o passwd_file=${HOME}/.passwd-s3fs

# Ensuring Persistent Mounting
echo 's3fs#mybucketname:/path/to/dir /path/to/local/mountpoint fuse _netdev,allow_other 0 0' | sudo tee -a /etc/fstab
```

{{< /note >}}

{{< note title="resize disk" >}}

```bash
# 會在 FSTYPE 欄顯示 ext4 或 xfs
lsblk -f
# 擴大分割區 1 直到填滿整顆磁碟
# apt-get -y install cloud-guest-utils   # 內含 growpart
growpart /dev/xvda 1
# ext4 # xfs_growfs -d / # xfs
resize2fs /dev/xvda1
```

{{< /note >}}

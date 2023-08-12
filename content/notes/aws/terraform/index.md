---
title: AWS Terraform
weight: 100
menu:
  notes:
    name: terraform
    identifier: notes-aws-terraform
    parent: notes-aws
    weight: 10
---

{{< note title="Provider" >}}

```hcl
# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  access_key = "ABCDEFGHIJKLMNOPQRST"
  secret_key = "QUJDREVGR0hJSktMTU5PUFFSU1+RVVldYWVo"
}
```

{{< /note >}}

{{< note title="EC2" >}}

```hcl
# Create EC2 instance
resource "aws_instance" "Gitlab" {
  private_ip                  = "172.16.11.11"
  ami                         = "ami-0d52744d6551d851e"
  instance_type               = "c4.xlarge"
  subnet_id                   = "subnet-4f5984ff6a5265502"
  associate_public_ip_address = true
  key_name                    = "KEY"
  monitoring                  = true
  security_groups             = ["sg-6c25e1cf1622486d8"]
  vpc_security_group_ids      = ["sg-6c25e1cf1622486d8"]
  tags                        = { "Name" = "Gitlab", "Project" = "dev" }
  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }
}
```

{{< /note >}}

{{< note title="RDS" >}}

```hcl
# Create RDS cluster
resource "aws_rds_cluster" "dev-mysql" {
  cluster_identifier = "dev-mysql"
  availability_zones = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  database_name                   = "mydb"
  master_username                 = "admin"
  master_password                 = "password"
  engine                          = "aurora-mysql"
  engine_version                  = "8.0.mysql_aurora.3.03.1"
  engine_mode                     = "provisioned"
  vpc_security_group_ids          = ["sg-6c25e1cf1622486d8"]
  deletion_protection             = true
  backup_retention_period         = 7
  preferred_backup_window         = "18:28-18:58"
  preferred_maintenance_window    = "sat:16:50-sat:17:20"
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  tags                            = { "Name" = "dev-mysql", "Project" = "dev" }
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count                      = 2
  identifier                 = "dev-mysql-${count.index}"
  cluster_identifier         = aws_rds_cluster.dev-mysql.id
  instance_class             = "db.r5.large"
  engine                     = "aurora-mysql"
  engine_version             = "8.0.mysql_aurora.3.03.1"
  auto_minor_version_upgrade = true
  publicly_accessible        = true
  tags                       = { "Name" = "dev-mysql", "Project" = "dev" }
}
```

{{< /note >}}

{{< note title="MQ" >}}

```hcl
# Create MQ
resource "aws_mq_broker" "dev-mq" {
  broker_name                = "dev-mq"
  engine_type                = "RabbitMQ"
  engine_version             = "3.10.20"
  host_instance_type         = "mq.m5.large"
  auto_minor_version_upgrade = false
  publicly_accessible        = true
  deployment_mode            = "SINGLE_INSTANCE"
  maintenance_window_start_time {
    day_of_week = "THURSDAY"
    time_of_day = "21:00"
    time_zone   = "UTC"
  }
  subnet_ids = ["subnet-4f5984ff6a5265502"]

  user {
    username = "admin"
    password = "password"
  }
  tags = { "Name" = "dev-mq", "Project" = "dev" }
}
```

{{< /note >}}

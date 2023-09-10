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

  user_data = file("initial.bash")
}
```

{{< /note >}}

{{< note title="Elastic IP" >}}

```hcl
# Create Elastic IP
resource "aws_eip" "GitlabEIP" {
  instance = aws_instance.Gitlab.id
  tags     = { "Name" = "GitlabEIP", "Project" = "backend" }
}

# Associate EIP with instance
resource "aws_eip_association" "eip_association_Gitlab" {
  instance_id   = aws_instance.Gitlab.id
  allocation_id = aws_eip.GitlabEIP.id
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

{{< note title="Security Group" >}}

```hcl
resource "aws_security_group" "default" {
    name = "prod_default"
    description = "Default"
    vpc_id = "vpc-0666666o888888888"

    ingress {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "TCP"
      cidr_blocks = ["192.168.0.0/16", "192.123.168.234/32"]
    }

    tags = {
      Name = "prod_default"
    }
}
resource "aws_security_group" "nginx" {
    name = "prod_nginx"
    description = "Allow nginx"
    vpc_id = "vpc-0666666o888888888"

    ingress {
      description = "TCP 443"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "prod_nginx"
    }
}
resource "aws_security_group" "db" {
    name = "prod_db"
    description = "Allow db"
    vpc_id = "vpc-0666666o888888888"

    ingress {
      description = "TCP 3306"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["192.168.11.0/24"]
    }

    ingress {
      description = "TCP 6050"
      from_port   = 6050
      to_port     = 6050
      protocol    = "tcp"
      cidr_blocks = ["192.168.11.0/24"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["192.168.11.0/24"]
    }

    tags = {
      Name = "prod_db"
    }
}
resource "aws_security_group" "pm2" {
    name = "prod_pm2"
    description = "Allow pm2"
    vpc_id = "vpc-0666666o888888888"

    ingress {
      description = "TCP 87-97"
      from_port   = 87
      to_port     = 97
      protocol    = "tcp"
      cidr_blocks = ["192.168.11.0/24"]
    }

    ingress {
      description = "TCP 3000"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["192.168.11.0/24"]
    }

    ingress {
      description = "TCP 7070"
      from_port   = 7070
      to_port     = 7070
      protocol    = "tcp"
      cidr_blocks = ["192.168.11.0/24"]
    }

    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["192.168.11.0/24", "1.1.1.1/32"]
    }

    tags = {
      Name = "prod_pm2"
    }
}
```

{{< /note >}}

{{< note title="VPC" >}}

```hcl
resource "aws_vpc" "vpc01" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-test-01"
  }
}

resource "aws_internet_gateway" "gateway01" {
  vpc_id = aws_vpc.vpc01.id
  tags = {
    Name = "SNAT-test-01"
  }
}

resource "aws_subnet" "subnet01" {
  vpc_id = aws_vpc.vpc01.id
  cidr_block = "192.168.10.0/24"
  tags = {
    Name = "subnet-test-01"
  }
}
```

{{< /note >}}

{{< note title="WAF" >}}

```hcl
resource "aws_wafv2_web_acl" "web_acl1" {
  name        = "prod-wss-test"
  description = "For prod wss"
  scope       = "CLOUDFRONT"  # CLOUDFRONT(must also specify the region us-east-1 (N. Virginia)), REGIONAL

  default_action {
    allow {}
  }

  rule {
    name     = "block-ip"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-ip"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-country"
    priority = 2

    action {
      block {}
    }

    statement {
      geo_match_statement {
        country_codes = ["US"]
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-country"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-query"
    priority = 3

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "EXACTLY"  # EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD
        search_string = "/abc"
        text_transformation {
          priority = 1
          type = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-rule-block-query"
      sampled_requests_enabled   = true
    }
  }

  tags = {
    Tag1 = "Value1"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl-prod-wss-test"
    sampled_requests_enabled   = true
  }
}

data "aws_cloudfront_distribution" "test" {
  arn = "arn:aws:cloudfront::123456789012:distribution/EATDVGD171BHDS1"
}

resource "aws_wafv2_web_acl_association" "enable_web_acl" {
  resource_arn = aws_cloudfront_distribution.test.arn
  web_acl_arn  = aws_wafv2_web_acl.web_acl1.arn
}
```

{{< /note >}}

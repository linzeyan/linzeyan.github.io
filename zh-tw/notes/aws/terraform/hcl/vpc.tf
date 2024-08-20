resource "aws_vpc" "vpc01" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
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
  vpc_id     = aws_vpc.vpc01.id
  cidr_block = "192.168.10.0/24"
  tags = {
    Name = "subnet-test-01"
  }
}

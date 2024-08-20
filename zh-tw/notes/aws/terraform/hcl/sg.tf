resource "aws_security_group" "default" {
  name        = "prod_default"
  description = "Default"
  vpc_id      = "vpc-0666666o888888888"

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
  name        = "prod_nginx"
  description = "Allow nginx"
  vpc_id      = "vpc-0666666o888888888"

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
  name        = "prod_db"
  description = "Allow db"
  vpc_id      = "vpc-0666666o888888888"

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
  name        = "prod_pm2"
  description = "Allow pm2"
  vpc_id      = "vpc-0666666o888888888"

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

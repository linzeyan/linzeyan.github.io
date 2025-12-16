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

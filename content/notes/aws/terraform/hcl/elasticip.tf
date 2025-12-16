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

# Create RDS cluster
resource "aws_rds_cluster" "dev-mysql" {
  cluster_identifier              = "dev-mysql"
  availability_zones              = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
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

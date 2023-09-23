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

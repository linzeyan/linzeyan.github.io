# replication
resource "aws_elasticache_replication_group" "replication" {
  replication_group_id       = "replication"
  description                = "replication redis"
  engine                     = "redis"
  engine_version             = "7.1"
  maintenance_window         = "sun:20:50-sun:21:50"
  node_type                  = "cache.m5.large"
  port                       = 6379
  parameter_group_name       = "default.redis7.cluster.on"
  security_group_ids         = ["sgid"]
  multi_az_enabled           = true
  automatic_failover_enabled = true
  apply_immediately          = true

  num_cache_clusters = 2
  tags               = { "Name" = "replication", "Project" = "replication" }

  # transit_encryption_enabled = true
  # auth_token                 = "477a2767fa27931db11a3581100a4124b5720f6b6468ddd64062170cec157185"

  log_delivery_configuration {
    destination      = "redis-slow"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = "redis-engine"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}

# cluster
resource "aws_elasticache_cluster" "cluster" {
  cluster_id           = "cluster"
  engine               = "redis"
  node_type            = "cache.m5.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.1"
  maintenance_window   = "sun:20:50-sun:21:50"
  security_group_ids   = ["sgid"]
  port                 = 6379
  tags                 = { "Name" = "cluster", "Project" = "cluster" }

  # transit_encryption_enabled = true
  # auth_token                 = "477a2767fa27931db11a3581100a4124b5720f6b6468ddd64062170cec157185"

  log_delivery_configuration {
    destination      = "redis-slow-cluster"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
  log_delivery_configuration {
    destination      = "redis-engine-cluster"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}

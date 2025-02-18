resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.cluster_name
  engine                 = "aurora-postgresql"
  engine_version         = "16.6"
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  storage_encrypted      = true
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
    seconds_until_auto_pause = 3600
  }
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
}


resource "aws_db_subnet_group" "main" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids
}


resource "aws_rds_cluster_instance" "aurora_instances" {
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.aurora.engine
  engine_version     = aws_rds_cluster.aurora.engine_version
}
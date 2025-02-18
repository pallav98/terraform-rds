resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = var.cluster_name
  engine                 = "aurora-postgresql"
  engine_version         = "15.3"
  database_name          = var.db_name
  master_username        = var.db_username
  master_password        = var.db_password
  storage_encrypted      = true
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }
  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true
}


resource "aws_db_subnet_group" "main" {
  name       = "aurora-subnet-group"
  subnet_ids = var.subnet_ids
}

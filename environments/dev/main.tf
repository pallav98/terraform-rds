resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!@#%^&*()-_=+[]{}<>?"
}

resource "aws_secretsmanager_secret" "rds_password" {
  name = "rds/db-password"
}

resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.db_password.result
}

module "rds" {
  source            = "../../modules/rds"
  cluster_name      = "dev-aurora"
  db_name           = "devdb"
  db_username       = "dbadmin"
  db_password       = random_password.db_password.result
  subnet_ids        = data.aws_subnets.private_subnets.ids
  security_group_id = data.aws_security_group.existing_sg.id
}
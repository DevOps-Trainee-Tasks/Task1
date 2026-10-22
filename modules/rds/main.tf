resource "aws_db_subnet_group" "database" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "postgres" {
  identifier                  = var.identifier
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  storage_type                = var.storage_type
  storage_encrypted           = true
  db_name                     = var.db_name
  username                    = var.username
  manage_master_user_password = true
  db_subnet_group_name        = aws_db_subnet_group.database.name
  vpc_security_group_ids      = [var.security_group_id]
  publicly_accessible         = false
  port                        = var.port
  multi_az                    = var.multi_az
  backup_retention_period     = var.backup_retention_period
  skip_final_snapshot         = var.skip_final_snapshot
}

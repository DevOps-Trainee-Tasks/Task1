resource "aws_db_subnet_group" "database" {
  name       = var.subnet_group_name
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
  publicly_accessible         = var.publicly_accessible
  port                        = var.port
  multi_az                    = var.multi_az
  backup_retention_period     = var.backup_retention_period
  skip_final_snapshot         = var.skip_final_snapshot
}

resource "aws_iam_role_policy" "pgvector_secret" {
  name = var.pgvector_policy_name
  role = var.bastion_role_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = aws_db_instance.postgres.master_user_secret[0].secret_arn
    }]
  })
}

resource "aws_ssm_association" "pgvector" {
  name             = "AWS-RunShellScript"
  association_name = var.pgvector_association_name

  targets {
    key    = "InstanceIds"
    values = [var.bastion_instance_id]
  }

  parameters = {
    commands = templatefile(var.pgvector_init_script_path, {
      aws_region       = var.aws_region
      secret_arn       = aws_db_instance.postgres.master_user_secret[0].secret_arn
      database_address = aws_db_instance.postgres.address
      database_port    = var.port
      database_name    = var.db_name
    })
    executionTimeout = tostring(var.pgvector_execution_timeout_seconds)
  }

  wait_for_success_timeout_seconds = var.pgvector_wait_timeout_seconds

  # The association needs the secret permission before it runs on the bastion.
  depends_on = [aws_iam_role_policy.pgvector_secret]
}

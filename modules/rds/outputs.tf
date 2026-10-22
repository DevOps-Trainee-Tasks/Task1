output "endpoint" {
  description = "Private PostgreSQL endpoint and port."
  value       = aws_db_instance.postgres.endpoint
}

output "address" {
  description = "Private PostgreSQL hostname for initialization."
  value       = aws_db_instance.postgres.address
}

output "master_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

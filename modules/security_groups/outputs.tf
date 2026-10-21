output "bastion_security_group_id" {
  description = "Security group ID for the bastion."
  value       = aws_security_group.bastion.id
}

output "alb_security_group_id" {
  description = "Security group ID for the load balancer."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for the application instances."
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group ID for PostgreSQL."
  value       = aws_security_group.db.id
}

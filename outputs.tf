output "bastion_public_ip" {
  description = "Public IPv4 address of the Bastion Host."
  value       = module.bastion.public_ip
}

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = module.alb.dns_name
}

output "database_endpoint" {
  description = "Private PostgreSQL endpoint and port."
  value       = module.rds.endpoint
}

output "database_master_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret."
  value       = module.rds.master_secret_arn
}

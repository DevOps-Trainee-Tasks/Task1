output "bastion_public_ip" {
  description = "Public IPv4 address of the Bastion Host."
  value       = module.bastion.public_ip
}

output "alb_endpoints" {
  description = "Public Ollama API URLs."
  value = {
    url      = "http://${module.alb.dns_name}"
    api_tags = "http://${module.alb.dns_name}/api/tags"
  }
}

output "database_endpoint" {
  description = "Private PostgreSQL endpoint and port."
  value       = module.rds.endpoint
}

output "database_master_secret_arn" {
  description = "ARN of the RDS-managed master credentials secret."
  value       = module.rds.master_secret_arn
}

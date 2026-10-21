output "security_group_ids" {
  description = "Security group IDs keyed by the configured logical names."
  value       = { for key, group in aws_security_group.security_groups : key => group.id }
}

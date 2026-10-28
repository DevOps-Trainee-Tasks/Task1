# Wait for rules before instances bootstrap or the ALB starts serving traffic.

output "bastion_id" {
  description = "Bastion security group ID, with its rules ready."
  value       = aws_security_group.bastion.id
  depends_on = [
    aws_vpc_security_group_ingress_rule.bastion_ssh,
    aws_vpc_security_group_egress_rule.bastion_to_application,
    aws_vpc_security_group_egress_rule.bastion_to_database,
    aws_vpc_security_group_egress_rule.bastion_http,
    aws_vpc_security_group_egress_rule.bastion_https,
  ]
}

output "alb_id" {
  description = "Alb security group ID, with its rules ready."
  value       = aws_security_group.alb.id
  depends_on = [
    aws_vpc_security_group_ingress_rule.alb_http,
    aws_vpc_security_group_egress_rule.alb_to_application,
  ]
}

output "application_id" {
  description = "Application security group ID, with its rules ready."
  value       = aws_security_group.application.id
  depends_on = [
    aws_vpc_security_group_ingress_rule.application_ssh,
    aws_vpc_security_group_ingress_rule.application_from_alb,
    aws_vpc_security_group_egress_rule.application_to_database,
    aws_vpc_security_group_egress_rule.application_http,
    aws_vpc_security_group_egress_rule.application_https,
  ]
}

output "database_id" {
  description = "Database security group ID, with its rules ready."
  value       = aws_security_group.database.id
  depends_on = [
    aws_vpc_security_group_ingress_rule.database_from_application,
    aws_vpc_security_group_ingress_rule.database_from_bastion,
  ]
}

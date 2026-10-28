output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main.id
}

# Consumers must wait for routing before starting their bootstrap scripts.
output "public_subnet_ids" {
  description = "Public subnet IDs in CIDR list order, ready for internet access."
  value       = aws_subnet.public[*].id
  depends_on  = [aws_route.internet, aws_route_table_association.public]
}

output "application_subnet_ids" {
  description = "Application subnet IDs in CIDR list order, ready for NAT access."
  value       = aws_subnet.application[*].id
  depends_on  = [aws_route.nat, aws_route.internet, aws_route_table_association.public, aws_route_table_association.application]
}

output "database_subnet_ids" {
  description = "Database subnet IDs in CIDR list order."
  value       = aws_subnet.database[*].id
  depends_on  = [aws_route.nat, aws_route_table_association.database]
}

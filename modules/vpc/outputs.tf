output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.network.id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets."
  value       = aws_subnet.public[*].id
}

output "app_subnet_ids" {
  description = "IDs of the two private application subnets."
  value       = aws_subnet.app[*].id
}

output "db_subnet_ids" {
  description = "IDs of the two private database subnets."
  value       = aws_subnet.db[*].id
}

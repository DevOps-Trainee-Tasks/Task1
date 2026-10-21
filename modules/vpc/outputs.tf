output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.main_vpc.id
}

output "subnet_ids" {
  description = "Subnet IDs grouped in the same order as their configured CIDR lists."
  value = {
    for group_name, group in var.subnet_groups : group_name => [
      for index in range(length(group.cidrs)) : aws_subnet.subnets["${group_name}-${index}"].id
    ]
  }
}

variable "project_name" {
  description = "Project prefix used for AWS Name tags."
  type        = string
}

variable "resource_names" {
  description = "Names for the VPC, Internet gateway, NAT gateway, and NAT Elastic IP."
  type = object({
    vpc              = string
    internet_gateway = string
    nat_gateway      = string
    nat_eip          = string
  })
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "enable_dns_support" {
  description = "Whether the VPC supports DNS resolution."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Whether the VPC assigns DNS hostnames."
  type        = bool
}

variable "availability_zones" {
  description = "Availability zones assigned to each subnet group in round-robin order."
  type        = list(string)
}

variable "enable_internet_gateway" {
  description = "Whether to create an Internet gateway and its configured routes."
  type        = bool
}

variable "enable_nat_gateway" {
  description = "Whether to create one NAT gateway, its Elastic IP, and configured routes."
  type        = bool
}

variable "subnet_groups" {
  description = "Subnet groups, their CIDRs, public IP behavior, and route table keys."
  type = map(object({
    cidrs                   = list(string)
    map_public_ip_on_launch = bool
    route_table             = string
    name_prefix             = string
  }))
}

variable "route_tables" {
  description = "Route tables with a default route through the internet or NAT gateway."
  type = map(object({
    destination_cidr_block = string
    gateway                = string
    name                   = string
  }))
}

variable "nat_gateway_subnet" {
  description = "Subnet group and zero-based subnet index that hosts the NAT gateway."
  type = object({
    group = string
    index = number
  })
}

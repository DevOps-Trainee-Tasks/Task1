variable "vpc_cidr" {
  description = "IPv4 CIDR for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "AZs cycled independently for public, application, and database subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs in allocation order."
  type        = list(string)
}

variable "application_subnet_cidrs" {
  description = "Private application subnet CIDRs in allocation order."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "Private database subnet CIDRs in allocation order."
  type        = list(string)
}

variable "enable_dns_support" {
  description = "Enable DNS resolution in the VPC."
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
}

variable "public_subnet_public_ips" {
  description = "Automatically assign public IPs in public subnets."
  type        = bool
}

variable "private_subnet_public_ips" {
  description = "Automatically assign public IPs in private subnets; keep false."
  type        = bool
}

variable "nat_public_subnet_index" {
  description = "Zero-based public subnet index for the NAT Gateway."
  type        = number
}

variable "internet_cidr" {
  description = "Default route destination for internet traffic."
  type        = string
}

variable "vpc_name" {
  description = "Vpc name."
  type        = string
}

variable "internet_gateway_name" {
  description = "Internet gateway name."
  type        = string
}

variable "nat_gateway_name" {
  description = "Name tag for the NAT Gateway."
  type        = string
}

variable "nat_eip_name" {
  description = "Name tag for the NAT Elastic IP."
  type        = string
}

variable "public_subnet_name_prefix" {
  description = "Public subnet name prefix."
  type        = string
}

variable "application_subnet_name_prefix" {
  description = "Application subnet name prefix."
  type        = string
}

variable "database_subnet_name_prefix" {
  description = "Database subnet name prefix."
  type        = string
}

variable "public_route_table_name" {
  description = "Public route table name."
  type        = string
}

variable "private_route_table_name" {
  description = "Private route table name."
  type        = string
}

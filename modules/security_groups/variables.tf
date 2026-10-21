variable "name" {
  description = "Prefix for security group names."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID from the VPC module."
  type        = string
}

variable "ssh_cidr" {
  description = "Your public IP in CIDR form for bastion SSH, for example 203.0.113.10/32."
  type        = string

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0)) && var.ssh_cidr != "0.0.0.0/0"
    error_message = "Provide a valid, restricted CIDR for SSH access."
  }
}


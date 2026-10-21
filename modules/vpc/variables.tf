variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Two availability zones for the subnets."
  type        = list(string)

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Provide two different availability zones."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for two public subnets, one per availability zone."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Provide exactly two public subnet CIDRs."
  }
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for two private application subnets."
  type        = list(string)

  validation {
    condition     = length(var.app_subnet_cidrs) == 2
    error_message = "Provide exactly two application subnet CIDRs."
  }
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for two private database subnets."
  type        = list(string)

  validation {
    condition     = length(var.db_subnet_cidrs) == 2
    error_message = "Provide exactly two database subnet CIDRs."
  }
}

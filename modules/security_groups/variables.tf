variable "vpc_id" {
  description = "VPC ID for the security groups."
  type        = string
}

variable "security_groups" {
  description = "Security groups and their ingress and egress rule sets. Ports are TCP or UDP; use protocol -1 with an empty ports list for all traffic."
  type = map(object({
    name        = string
    description = string
    ingress = map(object({
      protocol               = string
      ports                  = list(number)
      cidr_blocks            = list(string)
      source_security_groups = list(string)
    }))
    egress = map(object({
      protocol               = string
      ports                  = list(number)
      cidr_blocks            = list(string)
      source_security_groups = list(string)
    }))
  }))
}

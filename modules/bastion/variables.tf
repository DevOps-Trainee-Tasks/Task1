variable "ami_id" {
  description = "AMI ID for the Bastion Host."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Bastion Host."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID for the Bastion Host."
  type        = string
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs attached to the Bastion Host."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether the Bastion Host receives a public IPv4 address."
  type        = bool
}

variable "name" {
  description = "AWS Name tag for the Bastion Host."
  type        = string
}

variable "tags" {
  description = "Additional tags for the Bastion Host."
  type        = map(string)
}

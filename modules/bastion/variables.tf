variable "user_data_script_path" {
  description = "Path to the Bastion bootstrap script."
  type        = string
}

variable "ami_ssm_parameter_name" {
  description = "SSM public parameter holding the Bastion AMI ID."
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

variable "role_name" {
  description = "IAM role name for the Bastion."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the Bastion."
  type        = string
}

variable "name" {
  description = "AWS Name tag for the Bastion Host."
  type        = string
}

variable "tags" {
  description = "Additional tags for the Bastion Host."
  type        = map(string)
}

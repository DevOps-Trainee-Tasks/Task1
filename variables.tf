variable "ssh_cidr" {
  description = "Public IP in CIDR form allowed to reach the bastion over SSH."
  type        = string
}

variable "ec2_key_pair_name" {
  description = "Name of an existing EC2 key pair for Bastion and application SSH access."
  type        = string
}

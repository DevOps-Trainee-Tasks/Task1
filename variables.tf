variable "ssh_cidr" {
  description = "Approved public IPv4 CIDR for bastion SSH and ALB HTTP access."
  type        = string

}

variable "ec2_key_pair_name" {
  description = "Name of an existing EC2 key pair for Bastion and application SSH access."
  type        = string
}

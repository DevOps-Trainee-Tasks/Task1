variable "vpc_id" {
  description = "VPC ID for the security groups."
  type        = string
}

variable "bastion_name" {
  description = "Existing bastion security group name."
  type        = string
}

variable "alb_name" {
  description = "Existing alb security group name."
  type        = string
}

variable "application_name" {
  description = "Existing application security group name."
  type        = string
}

variable "database_name" {
  description = "Existing database security group name."
  type        = string
}

variable "allowed_client_cidr" {
  description = "Approved IPv4 CIDR for bastion SSH and ALB HTTP."
  type        = string
}

variable "internet_cidr" {
  description = "Internet destination for required HTTP and HTTPS downloads."
  type        = string
}

variable "ssh_port" {
  description = "Ssh TCP port."
  type        = number
}

variable "http_port" {
  description = "Http TCP port."
  type        = number
}

variable "https_port" {
  description = "Https TCP port."
  type        = number
}

variable "ollama_port" {
  description = "Ollama TCP port."
  type        = number
}

variable "postgres_port" {
  description = "Postgres TCP port."
  type        = number
}

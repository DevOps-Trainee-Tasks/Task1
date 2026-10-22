variable "name" {
  description = "Name of the application load balancer."
  type        = string
}

variable "internal" {
  description = "Whether the load balancer is internal."
  type        = bool
}

variable "subnet_ids" {
  description = "Subnets for the load balancer."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security groups for the load balancer."
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC for the target group."
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group."
  type        = string
}

variable "target_port" {
  description = "Port served by application instances."
  type        = number
}

variable "target_protocol" {
  description = "Protocol served by application instances."
  type        = string
}

variable "health_check_path" {
  description = "HTTP path used for target health checks."
  type        = string
}

variable "listener_port" {
  description = "Port exposed by the load balancer."
  type        = number
}

variable "listener_protocol" {
  description = "Protocol exposed by the load balancer."
  type        = string
}

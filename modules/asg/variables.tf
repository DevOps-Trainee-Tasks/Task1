variable "ami_id" {
  description = "AMI ID for application instances."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for application instances."
  type        = string
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair."
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the Auto Scaling Group."
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs attached to application instances."
  type        = list(string)
}

variable "target_group_arns" {
  description = "Load balancer target groups served by the application ASG."
  type        = list(string)
}

variable "health_check_grace_period" {
  description = "Seconds allowed for instance startup before ELB health checks affect scaling."
  type        = number
}

variable "health_check_type" {
  description = "Health check source used by the ASG."
  type        = string
}

variable "root_volume_size_gib" {
  description = "Size of the encrypted root EBS volume in GiB."
  type        = number
}

variable "root_volume_type" {
  description = "EBS volume type for the root disk."
  type        = string
}

variable "root_device_name" {
  description = "AMI root device name for the EBS block device mapping."
  type        = string
}

variable "min_size" {
  description = "Minimum number of application instances."
  type        = number
}

variable "desired_capacity" {
  description = "Initial desired number of application instances."
  type        = number
}

variable "max_size" {
  description = "Maximum number of application instances."
  type        = number
}

variable "cpu_target_value" {
  description = "Average CPU utilization target for scaling."
  type        = number
}

variable "scaling_metric_type" {
  description = "Predefined metric used for target tracking."
  type        = string
}

variable "ollama_model" {
  description = "Ollama model downloaded on each new instance."
  type        = string
}

variable "ollama_port" {
  description = "Private port used by the Ollama service."
  type        = number
}

variable "launch_template_name" {
  description = "Name of the EC2 Launch Template."
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group."
  type        = string
}

variable "scaling_policy_name" {
  description = "Name of the CPU target tracking policy."
  type        = string
}

variable "instance_name" {
  description = "AWS Name tag for application instances."
  type        = string
}

variable "tags" {
  description = "Additional tags for the Launch Template, ASG, and instances."
  type        = map(string)
}

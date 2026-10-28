variable "identifier" {
  description = "Name of the PostgreSQL DB instance."
  type        = string
}

variable "subnet_ids" {
  description = "Private database subnet IDs across two Availability Zones."
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group allowing PostgreSQL access from application instances."
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
}

variable "instance_class" {
  description = "RDS DB instance class."
  type        = string
}

variable "allocated_storage" {
  description = "Allocated database storage in GiB."
  type        = number
}

variable "storage_type" {
  description = "Database storage type."
  type        = string
}

variable "db_name" {
  description = "Initial application database name."
  type        = string
}

variable "username" {
  description = "Master username; the password is managed by RDS."
  type        = string
}

variable "port" {
  description = "PostgreSQL listener port."
  type        = number
}

variable "multi_az" {
  description = "Whether to deploy a standby DB instance in another Availability Zone."
  type        = bool
}

variable "backup_retention_period" {
  description = "Automated backup retention in days."
  type        = number
}

variable "skip_final_snapshot" {
  description = "Whether to omit a final snapshot when deleting the DB instance."
  type        = bool
}

variable "aws_region" {
  description = "AWS Region used by the pgvector initialization command."
  type        = string
}

variable "bastion_instance_id" {
  description = "Existing Bastion instance used to initialize pgvector."
  type        = string
}

variable "bastion_role_name" {
  description = "Bastion IAM role granted read access to the RDS-managed secret."
  type        = string
}

variable "pgvector_policy_name" {
  description = "Name of the Bastion policy for the RDS-managed secret."
  type        = string
}

variable "pgvector_association_name" {
  description = "Name of the one-time Systems Manager association."
  type        = string
}

variable "pgvector_execution_timeout_seconds" {
  description = "Maximum duration of the pgvector initialization command."
  type        = number
}

variable "pgvector_wait_timeout_seconds" {
  description = "Time Terraform waits for pgvector initialization to succeed."
  type        = number
}

variable "subnet_group_name" {
  description = "Existing RDS subnet group name."
  type        = string
}

variable "publicly_accessible" {
  description = "Whether RDS has public access; keep false for this private database."
  type        = bool
}

variable "pgvector_init_script_path" {
  description = "Root script template rendered with the RDS endpoint and secret ARN."
  type        = string
}

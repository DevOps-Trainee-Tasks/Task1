locals {
  aws_region             = "us-east-1"
  project_name           = "task1"
  availability_zones     = ["us-east-1a", "us-east-1b"]
  ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"

  vpc_cidr                  = "10.0.0.0/24"
  public_subnet_cidrs       = ["10.0.0.0/27", "10.0.0.32/27"]
  application_subnet_cidrs  = ["10.0.0.64/27", "10.0.0.96/27"]
  database_subnet_cidrs     = ["10.0.0.128/27", "10.0.0.160/27"]
  enable_dns_support        = true
  enable_dns_hostnames      = true
  public_subnet_public_ips  = true
  private_subnet_public_ips = false
  nat_public_subnet_index   = 0
  internet_cidr             = "0.0.0.0/0"
  ssh_port                  = 22
  http_port                 = 80
  https_port                = 443
  ollama_port               = 11434
  postgres_port             = 5432
  allowed_client_cidr       = var.ssh_cidr

  vpc_name                        = "${local.project_name}-main-vpc"
  internet_gateway_name           = "${local.project_name}-public-internet-gateway"
  nat_gateway_name                = "${local.project_name}-nat-gateway"
  nat_eip_name                    = "${local.project_name}-nat-elastic-ip"
  public_subnet_name_prefix       = "${local.project_name}-public-server-subnet"
  application_subnet_name_prefix  = "${local.project_name}-private-application-subnet"
  database_subnet_name_prefix     = "${local.project_name}-private-database-subnet"
  public_route_table_name         = "${local.project_name}-public-route-table"
  private_route_table_name        = "${local.project_name}-private-route-table"
  bastion_security_group_name     = "${local.project_name}-bastion-sg"
  alb_security_group_name         = "${local.project_name}-alb-sg"
  application_security_group_name = "${local.project_name}-application-sg"
  database_security_group_name    = "${local.project_name}-database-sg"

  bastion_instance_type         = "t3.micro"
  bastion_assign_public_ip      = true
  bastion_name                  = "${local.project_name}-bastion-server"
  bastion_role_name             = "${local.project_name}-bastion-role"
  bastion_instance_profile_name = "${local.project_name}-bastion-profile"

  application_instance_type     = "t3.small"
  application_assign_public_ip  = false
  root_volume_size_gib          = 20
  root_volume_type              = "gp3"
  root_device_name              = "/dev/xvda"
  asg_min_size                  = 2
  asg_desired_capacity          = 2
  asg_max_size                  = 4
  asg_cpu_target                = 75
  asg_health_check_type         = "ELB"
  asg_health_check_grace_period = 300
  ollama_model                  = "qwen2.5:0.5b"
  launch_template_name          = "${local.project_name}-application-launch-template"
  asg_name                      = "${local.project_name}-application-asg"
  scaling_policy_name           = "${local.project_name}-cpu-target-tracking"
  application_instance_name     = "${local.project_name}-ollama-application-server"

  alb_name          = "${local.project_name}-alb"
  alb_internal      = false
  target_group_name = "${local.project_name}-ollama"
  health_check_path = "/api/tags"

  database_identifier                = "${local.project_name}-postgres"
  database_subnet_group_name         = "${local.project_name}-postgres-subnets"
  database_name                      = "appdb"
  database_username                  = "appadmin"
  database_engine_version            = "16.15"
  database_instance_class            = "db.t4g.micro"
  database_allocated_storage         = 20
  database_storage_type              = "gp3"
  database_publicly_accessible       = false
  database_multi_az                  = false
  database_backup_retention          = 0
  database_skip_final_snapshot       = true
  pgvector_policy_name               = "${local.project_name}-db-secret-read"
  pgvector_association_name          = "${local.project_name}-pgvector"
  pgvector_execution_timeout_seconds = 1800
  pgvector_wait_timeout_seconds      = 2400
}

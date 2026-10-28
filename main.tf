module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                       = local.vpc_cidr
  availability_zones             = local.availability_zones
  public_subnet_cidrs            = local.public_subnet_cidrs
  application_subnet_cidrs       = local.application_subnet_cidrs
  database_subnet_cidrs          = local.database_subnet_cidrs
  enable_dns_support             = local.enable_dns_support
  enable_dns_hostnames           = local.enable_dns_hostnames
  public_subnet_public_ips       = local.public_subnet_public_ips
  private_subnet_public_ips      = local.private_subnet_public_ips
  nat_public_subnet_index        = local.nat_public_subnet_index
  internet_cidr                  = local.internet_cidr
  vpc_name                       = local.vpc_name
  internet_gateway_name          = local.internet_gateway_name
  nat_gateway_name               = local.nat_gateway_name
  nat_eip_name                   = local.nat_eip_name
  public_subnet_name_prefix      = local.public_subnet_name_prefix
  application_subnet_name_prefix = local.application_subnet_name_prefix
  database_subnet_name_prefix    = local.database_subnet_name_prefix
  public_route_table_name        = local.public_route_table_name
  private_route_table_name       = local.private_route_table_name
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id              = module.vpc.vpc_id
  bastion_name        = local.bastion_security_group_name
  alb_name            = local.alb_security_group_name
  application_name    = local.application_security_group_name
  database_name       = local.database_security_group_name
  allowed_client_cidr = local.allowed_client_cidr
  internet_cidr       = local.internet_cidr
  ssh_port            = local.ssh_port
  http_port           = local.http_port
  https_port          = local.https_port
  ollama_port         = local.ollama_port
  postgres_port       = local.postgres_port
}

module "bastion" {
  source = "./modules/bastion"

  user_data = file("${path.root}/scripts/bastion-user-data.sh")

  ami_ssm_parameter_name = local.ami_ssm_parameter_name
  instance_type          = local.bastion_instance_type
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_pair_name          = var.ec2_key_pair_name
  security_group_ids     = [module.security_groups.bastion_id]
  assign_public_ip       = local.bastion_assign_public_ip
  role_name              = local.bastion_role_name
  instance_profile_name  = local.bastion_instance_profile_name
  name                   = local.bastion_name
}

module "alb" {
  source = "./modules/alb"

  name               = local.alb_name
  internal           = local.alb_internal
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [module.security_groups.alb_id]
  vpc_id             = module.vpc.vpc_id
  target_group_name  = local.target_group_name
  target_port        = local.ollama_port
  health_check_path  = local.health_check_path
  listener_port      = local.http_port
}

module "asg" {
  source = "./modules/asg"

  user_data = templatefile("${path.root}/scripts/ollama-user-data.sh", {
    ollama_model = local.ollama_model
    ollama_port  = local.ollama_port
  })

  ami_ssm_parameter_name    = local.ami_ssm_parameter_name
  instance_type             = local.application_instance_type
  assign_public_ip          = local.application_assign_public_ip
  key_pair_name             = var.ec2_key_pair_name
  subnet_ids                = module.vpc.application_subnet_ids
  security_group_ids        = [module.security_groups.application_id]
  target_group_arns         = [module.alb.target_group_arn]
  health_check_type         = local.asg_health_check_type
  health_check_grace_period = local.asg_health_check_grace_period
  root_volume_size_gib      = local.root_volume_size_gib
  root_volume_type          = local.root_volume_type
  root_device_name          = local.root_device_name
  min_size                  = local.asg_min_size
  desired_capacity          = local.asg_desired_capacity
  max_size                  = local.asg_max_size
  cpu_target_value          = local.asg_cpu_target
  launch_template_name      = local.launch_template_name
  autoscaling_group_name    = local.asg_name
  scaling_policy_name       = local.scaling_policy_name
  instance_name             = local.application_instance_name
}

module "rds" {
  source = "./modules/rds"

  pgvector_init_script_path = "${path.root}/scripts/pgvector-init.sh"

  identifier                         = local.database_identifier
  subnet_group_name                  = local.database_subnet_group_name
  subnet_ids                         = module.vpc.database_subnet_ids
  security_group_id                  = module.security_groups.database_id
  engine_version                     = local.database_engine_version
  instance_class                     = local.database_instance_class
  allocated_storage                  = local.database_allocated_storage
  storage_type                       = local.database_storage_type
  db_name                            = local.database_name
  username                           = local.database_username
  port                               = local.postgres_port
  publicly_accessible                = local.database_publicly_accessible
  multi_az                           = local.database_multi_az
  backup_retention_period            = local.database_backup_retention
  skip_final_snapshot                = local.database_skip_final_snapshot
  aws_region                         = local.aws_region
  bastion_instance_id                = module.bastion.instance_id
  bastion_role_name                  = module.bastion.role_name
  pgvector_policy_name               = local.pgvector_policy_name
  pgvector_association_name          = local.pgvector_association_name
  pgvector_execution_timeout_seconds = local.pgvector_execution_timeout_seconds
  pgvector_wait_timeout_seconds      = local.pgvector_wait_timeout_seconds
}

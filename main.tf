module "vpc" {
  source = "./modules/vpc"

  project_name         = local.project_name
  vpc_cidr             = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  availability_zones   = ["us-east-1a", "us-east-1b"]

  resource_names = {
    vpc              = "main-vpc"
    internet_gateway = "public-internet-gateway"
    nat_gateway      = "nat-gateway"
    nat_eip          = "nat-elastic-ip"
  }

  enable_internet_gateway = true
  enable_nat_gateway      = true

  subnet_groups = {
    public = {
      cidrs                   = ["10.0.0.0/27", "10.0.0.32/27"]
      map_public_ip_on_launch = true
      route_table             = "public"
      name_prefix             = "public-server"
    }
    application = {
      cidrs                   = ["10.0.0.64/27", "10.0.0.96/27"]
      map_public_ip_on_launch = false
      route_table             = "private"
      name_prefix             = "private-application"
    }
    database = {
      cidrs                   = ["10.0.0.128/27", "10.0.0.160/27"]
      map_public_ip_on_launch = false
      route_table             = "private"
      name_prefix             = "private-database"
    }
  }

  nat_gateway_subnet = {
    group = "public"
    index = 0
  }

  route_tables = {
    public = {
      destination_cidr_block = "0.0.0.0/0"
      gateway                = "internet"
      name                   = "public-route-table"
    }
    private = {
      destination_cidr_block = "0.0.0.0/0"
      gateway                = "nat"
      name                   = "private-route-table"
    }
  }
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id = module.vpc.vpc_id

  security_groups = {
    bastion = {
      name        = "${local.project_name}-bastion-sg"
      description = "SSH access to the bastion"
      ingress = {
        ssh = {
          protocol               = "tcp"
          ports                  = [22]
          cidr_blocks            = [var.ssh_cidr]
          source_security_groups = []
        }
      }
      egress = {
        application_ssh = {
          protocol               = "tcp"
          ports                  = [22]
          cidr_blocks            = []
          source_security_groups = ["application"]
        }
        http = {
          protocol               = "tcp"
          ports                  = [80, 443]
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
        database = {
          protocol               = "tcp"
          ports                  = [local.postgres_port]
          cidr_blocks            = []
          source_security_groups = ["database"]
        }
      }
    }

    alb = {
      name        = "${local.project_name}-alb-sg"
      description = "HTTP access to the load balancer"
      ingress = {
        http = {
          protocol               = "tcp"
          ports                  = [local.http_port]
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
      }
      egress = {
        application = {
          protocol               = "tcp"
          ports                  = [local.ollama_port]
          cidr_blocks            = []
          source_security_groups = ["application"]
        }
      }
    }

    application = {
      name        = "${local.project_name}-application-sg"
      description = "Application instances in private subnets"
      ingress = {
        ssh = {
          protocol               = "tcp"
          ports                  = [22]
          cidr_blocks            = []
          source_security_groups = ["bastion"]
        }
        application = {
          protocol               = "tcp"
          ports                  = [local.ollama_port]
          cidr_blocks            = []
          source_security_groups = ["alb"]
        }
      }
      egress = {
        http = {
          protocol               = "tcp"
          ports                  = [80, 443]
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
        postgres = {
          protocol               = "tcp"
          ports                  = [local.postgres_port]
          cidr_blocks            = []
          source_security_groups = ["database"]
        }
      }
    }

    database = {
      name        = "${local.project_name}-database-sg"
      description = "PostgreSQL database in private subnets"
      ingress = {
        postgres = {
          protocol               = "tcp"
          ports                  = [local.postgres_port]
          cidr_blocks            = []
          source_security_groups = ["application"]
        }
        initializer = {
          protocol               = "tcp"
          ports                  = [local.postgres_port]
          cidr_blocks            = []
          source_security_groups = ["bastion"]
        }
      }
      egress = {}
    }
  }
}

module "alb" {
  source = "./modules/alb"

  name               = "${local.project_name}-alb"
  internal           = false
  subnet_ids         = module.vpc.subnet_ids["public"]
  security_group_ids = [module.security_groups.security_group_ids["alb"]]
  vpc_id             = module.vpc.vpc_id
  target_group_name  = "${local.project_name}-ollama"
  target_port        = local.ollama_port
  target_protocol    = "HTTP"
  health_check_path  = "/api/tags"
  listener_port      = local.http_port
  listener_protocol  = "HTTP"
}

module "bastion" {
  source = "./modules/bastion"

  ami_ssm_parameter_name = local.ami_ssm_parameter_name
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.subnet_ids["public"][0]
  key_pair_name          = var.ec2_key_pair_name
  security_group_ids     = [module.security_groups.security_group_ids["bastion"]]
  assign_public_ip       = true
  role_name              = "${local.project_name}-bastion-role"
  instance_profile_name  = "${local.project_name}-bastion-profile"
  name                   = "${local.project_name}-bastion-server"
  tags = {
    Project = local.project_name
    Role    = "bastion"
  }

  depends_on = [module.vpc, module.security_groups]
}

module "asg" {
  source = "./modules/asg"

  ami_ssm_parameter_name    = local.ami_ssm_parameter_name
  instance_type             = "t3.small"
  key_pair_name             = var.ec2_key_pair_name
  subnet_ids                = module.vpc.subnet_ids["application"]
  security_group_ids        = [module.security_groups.security_group_ids["application"]]
  target_group_arns         = [module.alb.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  root_volume_size_gib      = 20
  root_volume_type          = "gp3"
  root_device_name          = "/dev/xvda"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  cpu_target_value          = 75
  scaling_metric_type       = "ASGAverageCPUUtilization"
  ollama_model              = "qwen2.5:0.5b"
  ollama_port               = local.ollama_port
  launch_template_name      = "${local.project_name}-application-launch-template"
  autoscaling_group_name    = "${local.project_name}-application-asg"
  scaling_policy_name       = "${local.project_name}-cpu-target-tracking"
  instance_name             = "${local.project_name}-ollama-application-server"
  tags = {
    Project = local.project_name
    Role    = "ollama-application"
  }

  depends_on = [module.vpc, module.security_groups, module.alb]
}

module "rds" {
  source = "./modules/rds"

  identifier                         = "${local.project_name}-postgres"
  subnet_ids                         = module.vpc.subnet_ids["database"]
  security_group_id                  = module.security_groups.security_group_ids["database"]
  engine_version                     = "16.15"
  instance_class                     = "db.t4g.micro"
  allocated_storage                  = 20
  storage_type                       = "gp3"
  db_name                            = local.database_name
  username                           = "appadmin"
  port                               = local.postgres_port
  multi_az                           = false
  backup_retention_period            = 0
  skip_final_snapshot                = true
  aws_region                         = local.aws_region
  bastion_instance_id                = module.bastion.instance_id
  bastion_role_name                  = module.bastion.role_name
  pgvector_policy_name               = "${local.project_name}-db-secret-read"
  pgvector_association_name          = "${local.project_name}-pgvector"
  pgvector_execution_timeout_seconds = 1800
  pgvector_wait_timeout_seconds      = 2400

  depends_on = [module.security_groups]
}

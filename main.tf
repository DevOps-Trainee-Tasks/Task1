terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "amazon_linux_2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ssh_cidr" {
  description = "Public IP in CIDR form allowed to reach the bastion over SSH."
  type        = string
}

variable "ec2_key_pair_name" {
  description = "Name of an existing AWS EC2 key pair for Bastion and application SSH access."
  type        = string
}

locals {
  project_name         = "task1"
  ollama_port          = 11434
  ollama_model         = "qwen2.5:0.5b"
  asg_min_size         = 2
  asg_desired_capacity = 2
  asg_max_size         = 4
  asg_instance_type    = "t3.micro"
  cpu_target_value     = 75
}

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
        outbound = {
          protocol               = "-1"
          ports                  = []
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
      }
    }

    alb = {
      name        = "${local.project_name}-alb-sg"
      description = "HTTPS access to the load balancer"
      ingress = {
        https = {
          protocol               = "tcp"
          ports                  = [443]
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
      }
      egress = {
        application = {
          protocol               = "tcp"
          ports                  = [3000]
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
          ports                  = [3000]
          cidr_blocks            = []
          source_security_groups = ["alb"]
        }
        ollama = {
          protocol               = "tcp"
          ports                  = [local.ollama_port]
          cidr_blocks            = []
          source_security_groups = ["bastion"]
        }
      }
      egress = {
        outbound = {
          protocol               = "-1"
          ports                  = []
          cidr_blocks            = ["0.0.0.0/0"]
          source_security_groups = []
        }
      }
    }

    database = {
      name        = "${local.project_name}-database-sg"
      description = "PostgreSQL database in private subnets"
      ingress = {
        postgres = {
          protocol               = "tcp"
          ports                  = [5432]
          cidr_blocks            = []
          source_security_groups = ["application"]
        }
      }
      egress = {}
    }
  }
}

module "bastion" {
  source = "./modules/bastion"

  ami_id             = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.subnet_ids["public"][0]
  key_pair_name      = var.ec2_key_pair_name
  security_group_ids = [module.security_groups.security_group_ids["bastion"]]
  assign_public_ip   = true
  name               = "${local.project_name}-bastion-server"
  tags = {
    Project = local.project_name
    Role    = "bastion"
  }
}

module "asg" {
  source = "./modules/asg"

  ami_id                 = data.aws_ssm_parameter.amazon_linux_2023_ami.value
  instance_type          = local.asg_instance_type
  key_pair_name          = var.ec2_key_pair_name
  subnet_ids             = module.vpc.subnet_ids["application"]
  security_group_ids     = [module.security_groups.security_group_ids["application"]]
  root_volume_size_gib   = 20
  root_volume_type       = "gp3"
  root_device_name       = "/dev/xvda"
  min_size               = local.asg_min_size
  desired_capacity       = local.asg_desired_capacity
  max_size               = local.asg_max_size
  cpu_target_value       = local.cpu_target_value
  ollama_model           = local.ollama_model
  ollama_port            = local.ollama_port
  launch_template_name   = "${local.project_name}-application-launch-template"
  autoscaling_group_name = "${local.project_name}-application-asg"
  scaling_policy_name    = "${local.project_name}-cpu-target-tracking"
  instance_name          = "${local.project_name}-ollama-application-server"
  tags = {
    Project = local.project_name
    Role    = "ollama-application"
  }

  depends_on = [module.vpc, module.security_groups]
}

output "bastion_public_ip" {
  description = "Public IPv4 address of the Bastion Host."
  value       = module.bastion.public_ip
}

output "bastion_private_ip" {
  description = "Private IPv4 address of the Bastion Host."
  value       = module.bastion.private_ip
}

output "bastion_instance_id" {
  description = "EC2 instance ID of the Bastion Host."
  value       = module.bastion.instance_id
}

output "application_asg_name" {
  description = "Name of the Ollama application Auto Scaling Group."
  value       = module.asg.autoscaling_group_name
}

output "application_launch_template_id" {
  description = "Launch template ID used by the Ollama application ASG."
  value       = module.asg.launch_template_id
}

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

variable "ssh_cidr" {
  description = "Public IP in CIDR form allowed to reach the bastion over SSH."
  type        = string
}

locals {
  project_name = "task1"
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

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
  description = "Public IP for SSH access to the bastion."
  type        = string
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr           = "10.0.0.0/24"
  availability_zones = ["us-east-1a", "us-east-1b"]

  public_subnet_cidrs = ["10.0.0.0/27", "10.0.0.32/27"]
  app_subnet_cidrs    = ["10.0.0.64/27", "10.0.0.96/27"]
  db_subnet_cidrs     = ["10.0.0.128/27", "10.0.0.160/27"]
}

module "security_groups" {
  source = "./modules/security_groups"

  name     = "task1"
  vpc_id   = module.vpc.vpc_id
  ssh_cidr = var.ssh_cidr
}

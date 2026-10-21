terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  subnets = merge([
    for group_name, group in var.subnet_groups : {
      for index, cidr in group.cidrs : "${group_name}-${index}" => {
        index                   = index
        cidr                    = cidr
        map_public_ip_on_launch = group.map_public_ip_on_launch
        route_table             = group.route_table
        name                    = "${var.project_name}-${group.name_prefix}-subnet-${index + 1}"
      }
    }
  ]...)
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = "${var.project_name}-${var.resource_names.vpc}"
  }
}

resource "aws_internet_gateway" "public_internet_gateway" {
  count = var.enable_internet_gateway ? 1 : 0

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-${var.resource_names.internet_gateway}"
  }
}

resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = var.availability_zones[each.value.index % length(var.availability_zones)]
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name = each.value.name
  }
}

resource "aws_route_table" "route_tables" {
  for_each = var.route_tables

  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.project_name}-${each.value.name}"
  }
}

resource "aws_route" "internet_gateway_routes" {
  for_each = {
    for name, route in var.route_tables : name => route
    if route.gateway == "internet" && var.enable_internet_gateway
  }

  route_table_id         = aws_route_table.route_tables[each.key].id
  destination_cidr_block = each.value.destination_cidr_block
  gateway_id             = aws_internet_gateway.public_internet_gateway[0].id
}

resource "aws_eip" "nat_elastic_ip" {
  count = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.resource_names.nat_eip}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_elastic_ip[0].id
  subnet_id     = aws_subnet.subnets["${var.nat_gateway_subnet.group}-${var.nat_gateway_subnet.index}"].id

  tags = {
    Name = "${var.project_name}-${var.resource_names.nat_gateway}"
  }

  depends_on = [aws_internet_gateway.public_internet_gateway]
}

resource "aws_route" "nat_gateway_routes" {
  for_each = {
    for name, route in var.route_tables : name => route
    if route.gateway == "nat" && var.enable_nat_gateway
  }

  route_table_id         = aws_route_table.route_tables[each.key].id
  destination_cidr_block = each.value.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat_gateway[0].id
}

resource "aws_route_table_association" "subnet_route_table_associations" {
  for_each = local.subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.route_tables[each.value.route_table].id
}


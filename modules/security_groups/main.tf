terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

locals {
  rules = flatten([
    for security_group_key, security_group in var.security_groups : [
      for direction, rule_sets in {
        ingress = security_group.ingress
        egress  = security_group.egress
      } : [
        for rule_key, rule in rule_sets : [
          for port in concat(rule.ports, rule.protocol == "-1" ? [0] : []) : concat(
            [for cidr in rule.cidr_blocks : {
              security_group_key = security_group_key
              direction          = direction
              rule_key           = rule_key
              protocol           = rule.protocol
              port               = port
              source_type        = "cidr"
              source             = cidr
            }],
            [for source_group in rule.source_security_groups : {
              security_group_key = security_group_key
              direction          = direction
              rule_key           = rule_key
              protocol           = rule.protocol
              port               = port
              source_type        = "security_group"
              source             = source_group
            }]
          )
        ]
      ]
    ]
  ])
}

resource "aws_security_group" "security_groups" {
  for_each = var.security_groups

  name        = each.value.name
  description = each.value.description
  vpc_id      = var.vpc_id

  tags = {
    Name = each.value.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rules" {
  for_each = {
    for rule in local.rules : jsonencode([
      rule.security_group_key, rule.rule_key, rule.port, rule.source_type, rule.source
    ]) => rule if rule.direction == "ingress"
  }

  security_group_id            = aws_security_group.security_groups[each.value.security_group_key].id
  cidr_ipv4                    = each.value.source_type == "cidr" ? each.value.source : null
  referenced_security_group_id = each.value.source_type == "security_group" ? aws_security_group.security_groups[each.value.source].id : null
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.port
  to_port                      = each.value.protocol == "-1" ? null : each.value.port

  tags = {
    Name = "${var.security_groups[each.value.security_group_key].name}-${each.value.rule_key}-ingress-${each.value.protocol == "-1" ? "all" : tostring(each.value.port)}"
  }
}

resource "aws_vpc_security_group_egress_rule" "egress_rules" {
  for_each = {
    for rule in local.rules : jsonencode([
      rule.security_group_key, rule.rule_key, rule.port, rule.source_type, rule.source
    ]) => rule if rule.direction == "egress"
  }

  security_group_id            = aws_security_group.security_groups[each.value.security_group_key].id
  cidr_ipv4                    = each.value.source_type == "cidr" ? each.value.source : null
  referenced_security_group_id = each.value.source_type == "security_group" ? aws_security_group.security_groups[each.value.source].id : null
  ip_protocol                  = each.value.protocol
  from_port                    = each.value.protocol == "-1" ? null : each.value.port
  to_port                      = each.value.protocol == "-1" ? null : each.value.port

  tags = {
    Name = "${var.security_groups[each.value.security_group_key].name}-${each.value.rule_key}-egress-${each.value.protocol == "-1" ? "all" : tostring(each.value.port)}"
  }
}


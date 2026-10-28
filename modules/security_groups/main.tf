resource "aws_security_group" "bastion" {
  name        = var.bastion_name
  description = "SSH access to the bastion"
  vpc_id      = var.vpc_id
  tags        = { Name = var.bastion_name }
}

resource "aws_security_group" "alb" {
  name        = var.alb_name
  description = "HTTP access to the load balancer"
  vpc_id      = var.vpc_id
  tags        = { Name = var.alb_name }
}

resource "aws_security_group" "application" {
  name        = var.application_name
  description = "Application instances in private subnets"
  vpc_id      = var.vpc_id
  tags        = { Name = var.application_name }
}

resource "aws_security_group" "database" {
  name        = var.database_name
  description = "PostgreSQL database in private subnets"
  vpc_id      = var.vpc_id
  tags        = { Name = var.database_name }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.allowed_client_cidr
  ip_protocol       = "tcp"
  from_port         = var.ssh_port
  to_port           = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = var.allowed_client_cidr
  ip_protocol       = "tcp"
  from_port         = var.http_port
  to_port           = var.http_port
}

resource "aws_vpc_security_group_ingress_rule" "application_ssh" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = var.ssh_port
  to_port                      = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "application_from_alb" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = var.ollama_port
  to_port                      = var.ollama_port
}

resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.application.id
  ip_protocol                  = "tcp"
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_ingress_rule" "database_from_bastion" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_application" {
  security_group_id            = aws_security_group.bastion.id
  referenced_security_group_id = aws_security_group.application.id
  ip_protocol                  = "tcp"
  from_port                    = var.ssh_port
  to_port                      = var.ssh_port
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_database" {
  security_group_id            = aws_security_group.bastion.id
  referenced_security_group_id = aws_security_group.database.id
  ip_protocol                  = "tcp"
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
}

# HTTP/HTTPS downloads use changing public IPs; see README for the egress trade-off.
resource "aws_vpc_security_group_egress_rule" "bastion_http" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = "tcp"
  from_port         = var.http_port
  to_port           = var.http_port
}

resource "aws_vpc_security_group_egress_rule" "bastion_https" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = "tcp"
  from_port         = var.https_port
  to_port           = var.https_port
}

resource "aws_vpc_security_group_egress_rule" "alb_to_application" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.application.id
  ip_protocol                  = "tcp"
  from_port                    = var.ollama_port
  to_port                      = var.ollama_port
}

resource "aws_vpc_security_group_egress_rule" "application_to_database" {
  security_group_id            = aws_security_group.application.id
  referenced_security_group_id = aws_security_group.database.id
  ip_protocol                  = "tcp"
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
}

resource "aws_vpc_security_group_egress_rule" "application_http" {
  security_group_id = aws_security_group.application.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = "tcp"
  from_port         = var.http_port
  to_port           = var.http_port
}

resource "aws_vpc_security_group_egress_rule" "application_https" {
  security_group_id = aws_security_group.application.id
  cidr_ipv4         = var.internet_cidr
  ip_protocol       = "tcp"
  from_port         = var.https_port
  to_port           = var.https_port
}

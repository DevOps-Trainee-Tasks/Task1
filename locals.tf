locals {
  aws_region             = "us-east-1"
  project_name           = "task1"
  http_port              = 80
  ollama_port            = 11434
  postgres_port          = 5432
  database_name          = "appdb"
  ami_ssm_parameter_name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

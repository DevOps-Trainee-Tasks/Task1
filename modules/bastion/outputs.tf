output "public_ip" {
  description = "Public IPv4 address of the Bastion Host."
  value       = aws_instance.bastion_host.public_ip
}

output "instance_id" {
  description = "Bastion instance ID for the pgvector initialization association."
  value       = aws_instance.bastion_host.id
}

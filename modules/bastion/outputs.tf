output "public_ip" {
  description = "Public IPv4 address of the Bastion Host."
  value       = aws_instance.bastion_host.public_ip
}

output "private_ip" {
  description = "Private IPv4 address of the Bastion Host."
  value       = aws_instance.bastion_host.private_ip
}

output "instance_id" {
  description = "EC2 instance ID of the Bastion Host."
  value       = aws_instance.bastion_host.id
}

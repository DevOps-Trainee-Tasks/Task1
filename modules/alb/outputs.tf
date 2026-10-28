output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.application.dns_name
}

output "target_group_arn" {
  description = "Target group ARN for the application ASG."
  value       = aws_lb_target_group.application.arn
  # Register the ASG only once this target group has a forwarding listener.
  depends_on = [aws_lb_listener.application]
}

output "load_balancer_dns_name" {
  value = var.enabled ? aws_lb.this[0].dns_name : null
}

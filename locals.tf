locals {
  name = "portfolio-${var.environment}"
  common_tags = {
    Project     = "terraform-aws-production-environment"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

check "paid_runtime_requirements" {
  assert {
    condition     = !var.enable_runtime || (var.enable_nat_gateways && var.certificate_arn != null)
    error_message = "Runtime requires paid NAT gateways and a real ACM certificate ARN."
  }
}

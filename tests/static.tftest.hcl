mock_provider "aws" {
  mock_data "aws_region" { defaults = { region = "us-east-1" } }
}

run "safe_defaults" {
  command = plan

  assert {
    condition     = output.load_balancer_dns_name == null
    error_message = "Paid runtime must be disabled by default."
  }

  assert {
    condition     = length(output.public_subnet_ids) == 2 && length(output.private_subnet_ids) == 2
    error_message = "Network module must produce two public and two private subnets."
  }
}

run "reject_runtime_without_paid_dependencies" {
  command = plan

  variables { enable_runtime = true }
  expect_failures = [check.paid_runtime_requirements]
}

run "production_shape" {
  command = plan

  variables {
    environment         = "production"
    enable_runtime      = true
    enable_nat_gateways = true
    certificate_arn     = "arn:aws:acm:us-east-1:111122223333:certificate/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition     = var.environment == "production" && var.enable_runtime && var.enable_nat_gateways && var.desired_count >= 2
    error_message = "Production runtime must use the guarded, redundant service configuration."
  }
}

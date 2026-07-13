# Fake example values only. Do not deploy these unchanged.
environment        = "staging"
aws_region         = "us-east-1"
availability_zones = ["us-east-1a", "us-east-1b"]
vpc_cidr           = "10.42.0.0/16"

# Paid resources remain disabled in this safe example.
enable_runtime      = false
enable_nat_gateways = false
certificate_arn     = null
desired_count       = 2

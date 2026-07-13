variable "environment" {
  type        = string
  description = "Environment name used in resource names and tags."
  default     = "validation"
  validation {
    condition     = contains(["validation", "staging", "production"], var.environment)
    error_message = "Environment must be validation, staging, or production."
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region for real deployments."
  default     = "us-east-1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must resemble us-east-1."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "Exactly two availability zones in the selected region."
  default     = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "Provide exactly two distinct availability zones."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "RFC1918 CIDR for the VPC."
  default     = "10.42.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.vpc_cidr)) && startswith(var.vpc_cidr, "10.")
    error_message = "Use a valid 10.0.0.0/8 private CIDR."
  }
}

variable "enable_runtime" {
  type        = bool
  description = "Create paid ALB, ECS, and autoscaling resources. Disabled by default."
  default     = false
}

variable "enable_nat_gateways" {
  type        = bool
  description = "Create one paid NAT gateway per AZ for private task egress."
  default     = false
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN used by the HTTPS listener when runtime is enabled."
  default     = null
  nullable    = true
  validation {
    condition     = var.certificate_arn == null || can(regex("^arn:aws:acm:[a-z0-9-]+:[0-9]{12}:certificate/", var.certificate_arn))
    error_message = "Certificate ARN must be null or a syntactically valid ACM ARN."
  }
}

variable "container_image" {
  type        = string
  description = "Explicitly tagged image for the demonstration service."
  default     = "nginxinc/nginx-unprivileged:1.27.5-alpine"
  validation {
    condition     = !endswith(var.container_image, ":latest")
    error_message = "Container image must not use latest."
  }
}

variable "desired_count" {
  type        = number
  description = "Fargate task count when runtime is enabled."
  default     = 2
  validation {
    condition     = var.desired_count >= 2 && var.desired_count <= 6
    error_message = "Desired count must be between 2 and 6 for multi-AZ availability."
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Protect the production ALB from accidental deletion. Disable explicitly before destroy."
  default     = true
}

variable "storage_force_destroy" {
  type        = bool
  description = "Allow Terraform to delete a non-empty bucket. Keep false for production."
  default     = false
}

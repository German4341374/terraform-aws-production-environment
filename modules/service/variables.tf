variable "enabled" { type = bool }
variable "name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }
variable "certificate_arn" {
  type     = string
  nullable = true
}
variable "container_image" { type = string }
variable "desired_count" { type = number }
variable "deletion_protection" { type = bool }
variable "log_retention_days" { type = number }
variable "tags" { type = map(string) }

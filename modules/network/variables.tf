variable "name" { type = string }
variable "vpc_cidr" { type = string }
variable "availability_zones" { type = list(string) }
variable "enable_nat_gateways" { type = bool }
variable "enable_flow_logs" {
  type        = bool
  description = "Create CloudWatch VPC flow logs. Enabled with the paid runtime path."
}
variable "tags" { type = map(string) }

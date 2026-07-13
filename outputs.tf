output "vpc_id" { value = module.network.vpc_id }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "private_subnet_ids" { value = module.network.private_subnet_ids }
output "encrypted_bucket_name" {
  value       = module.storage.bucket_name
  description = "Infrastructure identifier hidden from routine console output."
  sensitive   = true
}
output "load_balancer_dns_name" {
  value       = module.service.load_balancer_dns_name
  description = "Null when paid runtime resources are disabled."
}

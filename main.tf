module "network" {
  source = "./modules/network"

  name                = local.name
  vpc_cidr            = var.vpc_cidr
  availability_zones  = var.availability_zones
  enable_nat_gateways = var.enable_nat_gateways
  enable_flow_logs    = var.enable_runtime
  tags                = local.common_tags
}

module "storage" {
  source = "./modules/storage"

  name          = local.name
  force_destroy = var.storage_force_destroy
  tags          = local.common_tags
}

module "service" {
  source = "./modules/service"

  enabled             = var.enable_runtime
  name                = local.name
  vpc_id              = module.network.vpc_id
  public_subnet_ids   = module.network.public_subnet_ids
  private_subnet_ids  = module.network.private_subnet_ids
  certificate_arn     = var.certificate_arn
  container_image     = var.container_image
  desired_count       = var.desired_count
  deletion_protection = var.enable_deletion_protection
  log_retention_days  = var.environment == "production" ? 90 : 30
  tags                = local.common_tags
}

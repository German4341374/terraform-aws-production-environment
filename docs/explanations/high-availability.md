# High availability and subnet design

Public and private subnets span two AZs. The ALB uses both public subnets, Fargate spreads tasks across
private subnets, and optional NAT gateways are per-AZ to avoid cross-AZ dependencies and data charges.
This survives many single-AZ failures but is not regional disaster recovery.

# ADR 0001: Fargate tasks in private subnets

Fargate removes instance management and tasks receive no public IP. HTTPS egress uses one NAT per AZ
for failure isolation. This is realistic but expensive; runtime and NAT are therefore opt-in.

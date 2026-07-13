# Destroy runbook

1. Confirm the environment/account and record a cost baseline.
2. Back up required S3 data, logs, and state; review retention obligations.
3. Run `terraform plan -destroy` with the exact production tfvars.
4. Obtain approval, run `scripts/destroy.sh`, and type `DESTROY-PAID-AWS`. This custom confirmation
   authorizes the script to disable ALB deletion protection and then execute destroy non-interactively.
5. Verify NAT gateways, EIPs, ALB, ECS, logs, and data resources in AWS and Cost Explorer.
6. Preserve remote-state infrastructure until all managed resources are verified absent.

#!/usr/bin/env bash
set -Eeuo pipefail
tfvars="${1:-example.tfvars}"
[[ -f "${tfvars}" ]] || { echo "Missing ${tfvars}." >&2; exit 1; }
aws sts get-caller-identity >/dev/null
echo "WARNING: A real plan may query AWS. Applying ALB, NAT, Fargate, logs, and storage costs money."
terraform plan -input=false -var-file="${tfvars}" -out=production.tfplan
terraform show -no-color production.tfplan > production-plan.txt

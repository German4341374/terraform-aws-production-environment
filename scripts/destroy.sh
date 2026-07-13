#!/usr/bin/env bash
set -Eeuo pipefail
tfvars="${1:-environments/production.tfvars.example}"
aws sts get-caller-identity >/dev/null
echo "Destroy may fail if deletion protection or non-empty storage is intentionally retained."
read -r -p "Type DESTROY-PAID-AWS to continue: " confirmation
[[ "${confirmation}" == "DESTROY-PAID-AWS" ]] || { echo "Destroy cancelled."; exit 1; }
echo "Disabling ALB deletion protection before destroy. Review this apply carefully."
terraform apply -input=false -auto-approve -var-file="${tfvars}" -var='enable_deletion_protection=false'
terraform destroy -input=false -auto-approve -var-file="${tfvars}" -var='enable_deletion_protection=false'

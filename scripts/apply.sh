#!/usr/bin/env bash
set -Eeuo pipefail
[[ -f production.tfplan ]] || { echo "Run scripts/plan.sh first." >&2; exit 1; }
echo "WARNING: This creates billable AWS resources."
read -r -p "Type APPLY-PAID-AWS to continue: " confirmation
[[ "${confirmation}" == "APPLY-PAID-AWS" ]] || { echo "Apply cancelled."; exit 1; }
terraform apply production.tfplan

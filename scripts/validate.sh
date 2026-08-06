#!/usr/bin/env bash
set -Eeuo pipefail
terraform init -backend=false
terraform fmt -check -recursive -diff
terraform validate
terraform test
tflint --recursive
trivy config --severity HIGH,CRITICAL --exit-code 1 --skip-dirs .terraform .

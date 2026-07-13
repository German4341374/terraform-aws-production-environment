#!/usr/bin/env bash
set -Eeuo pipefail
terraform init -backend=false
terraform fmt -check -recursive -diff
terraform validate
terraform test
tflint --recursive
checkov --directory . --framework terraform --quiet --compact

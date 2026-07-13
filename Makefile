SHELL := /bin/bash
.PHONY: setup fmt lint validate test plan up down clean
setup:
	terraform init -backend=false
fmt:
	terraform fmt -recursive
lint:
	terraform fmt -check -recursive -diff
	tflint --recursive
	checkov --directory . --framework terraform --quiet --compact
validate:
	terraform validate
test:
	terraform test
plan:
	bash scripts/plan.sh
up:
	bash scripts/apply.sh
down:
	bash scripts/destroy.sh
clean:
	rm -rf .terraform *.tfplan production-plan.txt

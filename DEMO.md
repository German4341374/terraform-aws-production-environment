# Five-Minute Portfolio Demonstration

This script demonstrates the project's design without an AWS account. Keep the repository and a terminal open before the meeting.

## 0:00-0:45 — Explain the goal

Open `README.md` and show the Mermaid diagram. Explain that the project models a small production AWS environment while keeping the default configuration free and safe: the paid ECS, NAT gateway, and load balancer path is disabled unless explicitly enabled.

## 0:45-1:30 — Show modular design

Open `main.tf` and the three directories under `modules/`:

- `network` creates the VPC, two public subnets, two private subnets, route tables, and optional NAT gateways;
- `service` creates an HTTPS Application Load Balancer, ECS Fargate service, auto scaling, IAM roles, and CloudWatch logs;
- `storage` creates a private, encrypted, versioned S3 bucket.

Point out `for_each` in the network module and conditional `count` in the service module.

## 1:30-2:30 — Run account-free validation

From WSL2 or Linux, run:

```bash
make setup
make lint
make test
```

Explain that `terraform init -backend=false` avoids remote state and that Terraform test uses a mocked AWS provider. The GitHub Actions workflow repeats formatting, validation, TFLint, Checkov, and tests without AWS credentials.

## 2:30-3:30 — Demonstrate safety controls

Open `variables.tf`, `locals.tf`, and `example.tfvars`. Highlight:

- input validation for environments, CIDRs, availability zones, image tags, and scaling limits;
- the check that requires both NAT gateways and an ACM certificate before runtime resources can be enabled;
- fake values only in examples;
- no access keys, automatic apply, or default paid runtime resources.

## 3:30-4:15 — Explain the production path

Open `environments/production.tfvars.example` and `backend.hcl.example`. Explain that an operator must first create a state bucket and lock-enabled backend, supply a real ACM certificate ARN, authenticate through an AWS profile or identity federation, review a saved plan, and explicitly type a confirmation before apply.

Mention that NAT gateways, the ALB, Fargate, CloudWatch, and S3 can incur charges.

## 4:15-5:00 — Close with operations and security

Open `docs/threat-model.md`, `docs/runbooks/destroy.md`, and the two GitHub Actions workflows. Summarize least-privilege IAM separation, private workloads, HTTPS-only ingress, encrypted storage, optional Infracost estimates, concurrency controls, and the documented destroy procedure.

Finish with this trade-off: private tasks and one NAT gateway per availability zone improve isolation and resilience, but increase cost. A production team could replace NAT egress with VPC endpoints where practical.

## Optional live AWS demonstration

Only use this section with a disposable AWS account and an approved budget. Never run it during an interview without permission.

```bash
cp environments/production.tfvars.example environments/production.tfvars
# Replace every fake value and review the cost warning.
bash scripts/plan.sh environments/production.tfvars
# Apply and destroy are deliberately separate, interactive actions.
```

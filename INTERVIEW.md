# Interview Questions and Answers

## 1. Why use two availability zones?

Two zones reduce the risk that one data-center failure removes every application task. The load balancer can route traffic to healthy tasks in either zone.

## 2. Why are application tasks in private subnets?

They should receive traffic only through the load balancer. Private placement removes direct internet ingress and reduces the exposed attack surface.

## 3. Why does the load balancer use public subnets?

An internet-facing Application Load Balancer needs routes to an internet gateway. Its security group exposes only HTTPS to clients.

## 4. What is the network flow?

A client connects over HTTPS to the ALB. The ALB forwards traffic to the task port over the VPC network. Tasks use NAT gateways for approved outbound internet access, and responses return through the ALB.

## 5. Why is runtime infrastructure disabled by default?

Static validation should be safe and free. NAT gateways, Fargate tasks, an ALB, logs, and data transfer can all create AWS charges.

## 6. Why require NAT gateways when enabling the service?

The sample tasks run in private subnets and need outbound access to pull public container images and send logs. A later design could use private ECR and VPC endpoints instead.

## 7. Why is HTTPS required?

TLS protects credentials and application data in transit. The module therefore requires an ACM certificate ARN before the runtime path can be enabled.

## 8. How does Auto Scaling work here?

Application Auto Scaling changes the ECS desired task count between configured minimum and maximum values, targeting average CPU utilization of 60 percent.

## 9. How is storage protected?

The S3 bucket blocks public access, uses server-side encryption, enables versioning, and removes old noncurrent versions after a retention period.

## 10. Why use separate ECS IAM roles?

The execution role lets the ECS agent write logs and perform startup operations. The task role is intentionally empty so application code receives no AWS permissions by default.

## 11. What does least privilege mean in this project?

Each identity receives only the actions and resources needed for its purpose. For example, the execution policy scopes CloudWatch Logs actions to the service log group.

## 12. What is Terraform state?

State maps Terraform resource addresses to real infrastructure and stores metadata needed to calculate changes. It may contain sensitive values and must not be committed.

## 13. Why use remote state?

A remote S3 backend gives a team one durable state location, encryption controls, version recovery, and locking support that prevents concurrent writers.

## 14. What is state locking?

Locking ensures only one state-changing Terraform operation runs at a time. This prevents two engineers from producing conflicting state updates.

## 15. Why is the backend only an example?

The state bucket must exist before Terraform initializes this configuration. Keeping backend settings external also permits free local validation with `-backend=false`.

## 16. How does testing work without AWS credentials?

Terraform test uses `mock_provider "aws"`, so configuration and assertions are evaluated against provider schemas without calling AWS APIs.

## 17. What do TFLint and Checkov add?

TFLint catches Terraform-specific quality and provider issues. Checkov performs static security and compliance checks. They complement, rather than replace, `terraform validate`.

## 18. Why pin tool and provider versions?

Pins make results more reproducible and prevent an unreviewed major release from changing behavior. Dependabot proposes controlled updates.

## 19. Why not run apply in GitHub Actions?

Pull requests are untrusted input, and automatic apply expands both security and financial risk. This project keeps deployment a reviewed, local, interactive operation.

## 20. How is high availability balanced against cost?

The design uses two zones, two or more tasks, and one optional NAT gateway per zone. That avoids a single-zone dependency but costs more than one NAT gateway or public tasks.

## 21. What happens when an ECS task fails its health check?

ECS replaces unhealthy tasks, while the target group stops routing requests to unhealthy targets. The service maintains the configured desired count.

## 22. Why use immutable container image tags?

An explicit version tag is more reproducible than `latest`. Production should go further and reference an image digest after vulnerability scanning.

## 23. What are the main remaining security improvements?

Add WAF, ALB access logs, VPC flow logs, KMS customer-managed keys where required, private ECR, VPC endpoints, AWS Config, and organization-level guardrails.

## 24. How would secrets reach the application?

Use Secrets Manager or Systems Manager Parameter Store with narrowly scoped task-role permissions. Never place secret values in tfvars, source control, or plain Terraform outputs.

## 25. How do you destroy the environment safely?

Review the state and dependencies, protect or export required data, run a destroy plan, then use the interactive destroy script. The state backend is managed separately and removed last under its own retention policy.

## 26. Why use reusable modules?

Modules isolate network, service, and storage responsibilities. Environment roots can reuse the same reviewed implementation with different validated inputs.

## 27. How would staging differ from production?

Staging could use fewer tasks and shorter log retention while preserving the same network boundaries and security controls. Environment-specific tfvars should contain only non-secret settings.

## 28. What is the purpose of the optional cost workflow?

It runs Infracost only when manually requested and when its API key is configured. It provides an estimate for review but is not a billing guarantee.

# Threat model

## Assets and trust boundaries

Assets include Terraform state, AWS identity, application availability, S3 data, logs, and budget.
Boundaries exist at GitHub, operator workstation, AWS APIs, internet-facing ALB, private subnets, and tasks.

| Threat | Control | Residual risk |
|---|---|---|
| Stolen long-lived AWS key | No keys; short-lived federation recommended | Compromised active session |
| Malicious pull request applies resources | Credential-free read-only CI; no apply | Maintainer may apply unreviewed code locally |
| Direct task access | No public IP; ingress only from ALB SG | ALB/application vulnerabilities |
| Plaintext or public storage | SSE, versioning, public-access block | Authorized misuse; SSE-S3 key-control limits |
| State disclosure or race | Encrypted/versioned S3 and lockfile example | Misconfigured backend IAM |
| Supply-chain image compromise | Explicit image tag, read-only root | Tag mutation; digest pinning still needed |
| Cost denial of service | Runtime off by default; autoscaling max 6; warnings | NAT/ALB and traffic charges |
| Log loss | CloudWatch retention and container insights | No cross-account archive |

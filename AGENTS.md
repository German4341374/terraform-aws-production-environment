# Agent Guidelines

- Never add AWS keys, account data, state, binary plans, or real certificate ARNs.
- Keep `enable_runtime` and NAT gateways disabled by default.
- Preserve mocked no-account tests and `terraform init -backend=false` static validation.
- Never add automatic apply to GitHub Actions.
- Keep IAM policies resource-scoped and document unavoidable wildcard permissions.
- Run fmt, validate, tests, TFLint, and Trivy Config; review cost and destroy impact.
- Update the threat model and state/destroy runbooks when architecture changes.

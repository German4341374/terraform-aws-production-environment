# Security Policy

Report vulnerabilities through GitHub private security advisories. Do not include credentials,
state, plan files, account IDs, or real ARNs. Use short-lived federated AWS credentials for any real
deployment. CI has no AWS credentials and cannot apply. Sensitive state must use encrypted S3,
versioning, least-privilege bucket access, and lock files. This example is not deployment authorization.

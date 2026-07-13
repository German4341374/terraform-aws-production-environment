# ADR 0002: Credential-free static CI

CI initializes without backend access and uses AWS provider mocks. It validates structure and policy
without credentials, account queries, costs, or mutation. Real account planning remains a reviewed local step.

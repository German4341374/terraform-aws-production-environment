# Contributing

Run `make setup`, `make lint`, `make validate`, and `make test`. Real plans require your own
short-lived AWS authentication and may query billable resources; applies are never part of CI.
Describe cost, IAM, network, state, and destroy impact in every pull request. Never commit state,
plans, credentials, account IDs, or real infrastructure values.

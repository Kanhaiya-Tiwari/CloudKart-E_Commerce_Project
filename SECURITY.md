# Security Policy

## Supported versions

Security fixes are applied to the current `master` branch.

## Reporting a vulnerability

Please do not open a public issue for suspected security vulnerabilities or exposed credentials. Instead, contact the repository owner privately through GitHub with:

- a clear description of the issue;
- affected files, components, or deployment configuration;
- reproducible steps or a proof of concept, when safe to share; and
- the potential impact.

Please allow time for the report to be reviewed before disclosing details publicly.

## Secret handling

Do not commit API keys, passwords, private keys, tokens, or production configuration values. Store sensitive values in the deployment platform's secret manager or CI/CD credential store, and use documented placeholders in examples.

If a credential is committed accidentally, revoke and rotate it immediately. Removing it from the latest commit does not remove it from Git history.

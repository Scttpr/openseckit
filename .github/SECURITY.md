# Security Policy

## Scope

- Bash scripts (`init.sh`, `ingest.sh`, `kit/*/scripts/fetch.sh`)
- Prompt templates in `kit/`
- GitHub Actions workflows

## Reporting a Vulnerability

1. **Do NOT open a public issue**
2. Use [private security advisory](https://github.com/Scttpr/openseckit/security/advisories/new)

## Response Time

- Acknowledgment: 48h
- Critical: 7 days
- High: 14 days
- Medium/Low: 30 days

## Security Measures

- ShellCheck on all bash scripts
- Gitleaks for secret detection

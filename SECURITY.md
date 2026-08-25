# Security Policy

This repository contains instructions and scripts that may be loaded or executed by local AI agents. Treat every skill, reference, workflow, and installer as untrusted supply-chain input until it has been reviewed.

## Reporting

Do not open a public issue for a secret, credential, command-injection path, malicious skill, or unsafe installer. Contact the repository owner privately through GitHub security contact options and include a minimal reproduction, affected commit, and impact.

## Supported versions

Only the latest tagged release and `main` receive security fixes. Pin a release tag or commit in automation; do not depend on an unreviewed moving branch.

## Maintainer requirements

- Never commit secrets or real credentials.
- Keep GitHub Actions permissions least-privilege and pin third-party actions to full commit SHAs.
- Run scripts in a temporary profile before touching a user profile.
- Require explicit confirmation for destructive actions, pushes, or installation scripts.
- Do not use remote script execution such as `irm | iex`.
- Review provenance and license metadata for imported skills.

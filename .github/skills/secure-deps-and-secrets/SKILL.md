---
name: Secure dependencies & secrets
description: Triage dependency vulnerabilities and secret leaks, propose safe remediations, and produce PR-ready patches without exposing sensitive data.
tools:
  - read_repository
  - search_code
  - run_shell
  - run_tests
---

## When to use
Use this skill when the user says:
- "Dependabot flagged vulnerabilities"
- "Code scanning found issues"
- "We may have committed a secret"
- "Help harden our GitHub Actions security"

## Core workflow
### 1) Establish context (no secrets)
- Identify language/ecosystem: Node, Python, Java, Go, etc.
- Find lockfiles and build config:
  - package-lock.json / pnpm-lock.yaml / yarn.lock
  - requirements*.txt / poetry.lock / Pipfile.lock
  - go.mod / go.sum
  - pom.xml / build.gradle
- Identify GitHub security signals:
  - .github/dependabot.yml
  - .github/workflows/*
  - any SARIF reports under code scanning outputs (if present)

### 2) Dependency vulnerability triage
For each reported CVE/advisory:
- Identify the vulnerable package and the version range.
- Determine if it’s direct or transitive dependency.
- Propose remediation in this order:
  1. Upgrade direct dependency to a non-vulnerable version
  2. If transitive: upgrade the parent dependency / adjust resolution overrides
  3. If no fix: document compensating control + isolate usage
- Produce PR-ready change:
  - update manifest + lockfile
  - run tests / build
  - include short changelog note

### 3) Secret leak response (safe, non-invasive)
If a secret may be committed:
- DO NOT print, echo, or paste the suspected secret value.
- Locate the file/commit path and show a REDACTED snippet.
- Recommend safe remediation:
  - rotate/revoke credential with the provider
  - remove secret from repo and CI logs
  - add scanning / pre-commit hooks
  - add .gitignore where appropriate
- If history rewrite is needed:
  - propose using official tools (e.g., git filter-repo) with a high-level checklist
  - avoid detailed step-by-step instructions that could be misused to conceal wrongdoing
  - emphasize coordinating with maintainers (force-push implications)

### 4) GitHub Actions hardening
- Prefer pinned action versions (commit SHA for high-risk actions)
- Use least-privilege permissions in workflow:
  - set default `permissions: read-all` and escalate per job
- Avoid `pull_request_target` unless necessary; if used, isolate untrusted code.
- Prevent secrets exposure:
  - do not pass secrets to steps that run untrusted code
  - use OIDC short-lived credentials where possible

## Output format
- Findings (bulleted, severity-tagged)
- Evidence (file paths + redacted snippets)
- Fix plan (minimal changes first)
- Patch (diff)
- Verification steps (tests/CI commands)
- Follow-up hardening (optional)

## Guardrails
- Never output secret values; always redact.
- Never suggest bypassing security controls or hiding leaks.
- If user requests exploit/weaponization, refuse and pivot to defensive guidance.

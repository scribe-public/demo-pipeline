---
name: scan-secrets
description: 'Scan repositories for secrets and sensitive information using Trivy. Use for: detecting secrets, credentials, API keys, passwords, security audits, vulnerability assessment, SAST scanning.'
argument-hint: 'Optional: target path (defaults to current directory)'
---

# Secret Scanning

## What This Skill Does

Performs comprehensive secret scanning using Aqua Security's Trivy scanner to detect:
- API keys and tokens
- Database credentials  
- Private keys and certificates
- Cloud provider credentials
- Generic passwords and secrets
- Custom secret patterns

## When to Use

- **Pre-commit checks**: Before committing code to prevent secret leaks
- **Security audits**: Regular repository scanning for compliance
- **CI/CD integration**: Automated secret detection in pipelines
- **Code reviews**: Validate pull requests don't contain secrets
- **Legacy code analysis**: Audit existing codebases for exposed credentials
- **DevSecOps**: Integrate security scanning into development workflow

## Quick Start

1. **Scan current directory**: Run [basic scan script](./scripts/scan-basic.sh)
2. **Scan specific paths**: Run [targeted scan](./scripts/scan-targeted.sh) with custom paths
3. **CI/CD integration**: Use [pipeline script](./scripts/scan-ci.sh) for automated checks
4. **Custom patterns**: Configure [custom rules](./scripts/scan-custom.sh) for organization-specific secrets

## Available Scripts

### Basic Scanning
- `./scripts/scan-basic.sh` - Quick scan of current directory
- `./scripts/scan-targeted.sh <path>` - Scan specific files/directories
- `./scripts/scan-verbose.sh` - Detailed scan with full output

### Advanced Features  
- `./scripts/scan-ci.sh` - CI/CD optimized with exit codes
- `./scripts/scan-custom.sh` - Custom secret patterns
- `./scripts/install-trivy.sh` - Install Trivy scanner

### Output Formats
- `./scripts/scan-json.sh` - JSON format for automation
- `./scripts/scan-sarif.sh` - SARIF format for GitHub Security tab
- `./scripts/scan-table.sh` - Human-readable table format

## Configuration

The scripts automatically:
- Install Trivy if not present
- Use sensible defaults for secret detection
- Exclude common false positives
- Support multiple output formats
- Integrate with GitHub Security APIs

## Integration Examples

### Pre-commit Hook
```bash
#!/bin/bash
./.github/skills/scan-secrets/scripts/scan-ci.sh
```

### GitHub Action
```yaml
- name: Scan for secrets
  run: ./.github/skills/scan-secrets/scripts/scan-ci.sh
```

### VS Code Task
```json
{
  "label": "Scan Secrets",
  "type": "shell", 
  "command": "./.github/skills/scan-secrets/scripts/scan-basic.sh"
}
```

## Troubleshooting

**Common Issues:**
- Trivy not installed: Run `./scripts/install-trivy.sh`
- Permission denied: Ensure scripts are executable (`chmod +x scripts/*.sh`)
- False positives: Edit custom patterns in `scan-custom.sh`
- Large repositories: Use `scan-targeted.sh` for specific paths

**Performance Tips:**
- Scan specific directories instead of entire repository
- Use `.trivyignore` file to exclude known false positives  
- Run targeted scans on changed files only in CI

## References

- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Secret Types Detected](./references/secret-types.md)
- [Configuration Guide](./references/configuration.md)
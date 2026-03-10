# Secret Scanning Configuration Guide

This guide covers configuration options for Trivy secret scanning and integration patterns.

## Basic Configuration

### Command Line Options

```bash
# Basic secret scan
trivy fs --security-checks secret .

# Specific severity levels
trivy fs --security-checks secret --severity HIGH,CRITICAL .

# Custom output format
trivy fs --security-checks secret --format json .

# Exit codes for CI/CD
trivy fs --security-checks secret --exit-code 2 .
```

### Output Formats

| Format | Use Case | Example |
|--------|----------|---------|
| `table` | Human readable | Default console output |
| `json` | Automation/parsing | API integration |
| `sarif` | GitHub Security | Security tab integration |
| `template` | Custom formatting | Custom reports |

## Exclusions and Filtering

### .trivyignore File

Create a `.trivyignore` file in your repository root:

```
# Ignore test files
test/**
tests/**
**/*_test.py
**/*_test.js

# Ignore documentation
docs/**
*.md
README*

# Ignore specific vulnerabilities by ID
CVE-2021-1234

# Ignore files by pattern
vendor/**
node_modules/**
.git/**
```

### Command Line Exclusions

```bash
# Skip directories
trivy fs --skip-dirs vendor,node_modules .

# Skip files by pattern
trivy fs --skip-files "**/*_test.py" .

# Custom severities only
trivy fs --severity HIGH,CRITICAL .
```

## CI/CD Integration Patterns

### GitHub Actions

```yaml
name: Secret Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Run Secret Scan
      run: |
        ./.github/skills/scan-secrets/scripts/scan-ci.sh
        
    - name: Upload SARIF
      if: always()
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: ./security-reports/secrets.sarif
```

### GitLab CI

```yaml
secret_scan:
  stage: security
  image: aquasec/trivy:latest
  script:
    - trivy fs --security-checks secret --format json --output secrets.json .
  artifacts:
    reports:
      security: secrets.json
  allow_failure: false
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    stages {
        stage('Secret Scan') {
            steps {
                sh './.github/skills/scan-secrets/scripts/scan-ci.sh'
                publishHTML([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'security-reports',
                    reportFiles: 'secrets.html',
                    reportName: 'Secret Scan Report'
                ])
            }
        }
    }
}
```

## Custom Secret Patterns

### Configuration File Format

Create `trivy-secret.yaml`:

```yaml
secrets:
  - id: my-org-api-key
    category: custom
    title: My Organization API Key
    description: Internal API key pattern
    regex: '\b(myorg[_-]?api[_-]?key)[_-]?([a-f0-9]{32})\b'
    keywords:
      - myorg_api_key
      - myorg-api-key
      - MYORG_API_KEY
```

### Using Custom Patterns

```bash
# With custom config file
trivy fs --secret-config trivy-secret.yaml .

# Multiple config files
trivy fs --secret-config custom1.yaml --secret-config custom2.yaml .
```

## Environment-Specific Configuration

### Development Environment

```bash
# Relaxed scanning for development
trivy fs --severity HIGH,CRITICAL --quiet .

# Skip common dev directories
trivy fs --skip-dirs "node_modules,vendor,.git,test,tests" .
```

### Production Environment

```bash
# Strict scanning with all severities
trivy fs --severity LOW,MEDIUM,HIGH,CRITICAL --exit-code 1 .

# Comprehensive output for audit
trivy fs --format json --output security-audit.json .
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
set -e

# Run secret scan on staged files only
git diff --cached --name-only | while read file; do
    if [[ -f "$file" ]]; then
        trivy fs --security-checks secret "$file" || exit 1
    fi
done
```

## Performance Optimization

### Large Repositories

```bash
# Scan only changed files
git diff --name-only HEAD~1 | xargs trivy fs --security-checks secret

# Skip binary files
trivy fs --skip-files "**/*.{exe,dll,so,dylib,bin}" .

# Limit file size
trivy fs --file-size-limit 10MB .
```

### Parallel Scanning

```bash
# Multiple directories in parallel
find . -type d -name "src*" | xargs -P 4 -I {} trivy fs {}
```

## Monitoring and Alerting

### Slack Integration

```bash
#!/bin/bash
# Send results to Slack
RESULT=$(trivy fs --format json . 2>/dev/null)
SECRETS_COUNT=$(echo "$RESULT" | jq '.Results[]?.Secrets // [] | length' | awk '{sum+=$1} END {print sum+0}')

if [ "$SECRETS_COUNT" -gt 0 ]; then
    curl -X POST -H 'Content-type: application/json' \
        --data "{'text':'🚨 $SECRETS_COUNT secrets detected in repository!'}" \
        "$SLACK_WEBHOOK_URL"
fi
```

### Email Alerts

```bash
#!/bin/bash
# Email notification script
if trivy fs --security-checks secret --quiet . >/dev/null 2>&1; then
    echo "✅ No secrets detected" 
else
    echo "❌ Secrets detected in repository!" | mail -s "Security Alert" admin@company.com
fi
```

## Troubleshooting

### Common Issues

1. **False Positives**
   - Add patterns to `.trivyignore`
   - Use `--skip-files` for test files
   - Adjust severity levels

2. **Performance Issues**
   - Use `--skip-dirs` for large vendor directories
   - Scan specific paths instead of entire repo
   - Set file size limits

3. **CI/CD Timeouts**
   - Use `--quiet` flag to reduce output
   - Implement incremental scanning
   - Cache Trivy database

### Debug Mode

```bash
# Enable debug logging
trivy fs --debug --security-checks secret .

# Verbose output
trivy fs --security-checks secret --slow .
```

## Best Practices Summary

1. **Start with basic scanning** and gradually add custom patterns
2. **Use appropriate severity levels** for different environments
3. **Implement incremental scanning** for large repositories
4. **Set up proper exclusions** to reduce false positives
5. **Integrate early** in the development workflow
6. **Monitor and alert** on scan results
7. **Educate the team** on secure coding practices
8. **Regular updates** of Trivy and secret patterns
9. **Document exceptions** and accepted risks
10. **Automate remediation** where possible
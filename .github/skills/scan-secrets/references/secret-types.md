# Secret Types Detected by Trivy

Trivy's secret scanner detects various types of sensitive information and credentials commonly found in source code.

## API Keys and Tokens

### Cloud Service Providers
- **AWS**
  - AWS Access Key ID
  - AWS Secret Access Key
  - AWS Session Token
  - AWS CloudFormation Templates
  
- **Google Cloud Platform**
  - GCP Service Account Keys
  - Google API Keys
  - Firebase Configuration
  
- **Microsoft Azure**
  - Azure Storage Account Keys
  - Azure Service Principal
  - Azure Function Keys

### Popular Services
- **GitHub**: Personal Access Tokens, Deploy Keys
- **GitLab**: Personal Access Tokens, Deploy Tokens
- **Docker Hub**: Authentication tokens
- **NPM**: Access tokens and authentication tokens
- **PyPI**: API tokens
- **Slack**: Bot tokens, webhooks, API tokens
- **Discord**: Bot tokens, webhook URLs
- **Stripe**: API keys (live and test)
- **SendGrid**: API keys
- **Mailgun**: API keys
- **Twilio**: Account SID and Auth Token

## Database Credentials

### Connection Strings
- MySQL connection strings with embedded passwords
- PostgreSQL URLs with credentials
- MongoDB connection strings
- Redis URLs with authentication
- SQLServer connection strings

### Database Passwords
- Hardcoded database passwords in configuration files
- Database credentials in environment variable assignments
- Connection pool configurations with passwords

## Private Keys and Certificates

### Cryptographic Keys
- RSA Private Keys (PEM format)
- SSH Private Keys
- PGP Private Keys
- X.509 Private Keys
- ECDSA Private Keys

### Certificates
- SSL/TLS Private Keys
- JWT Signing Keys
- API Signing Keys

## Generic Patterns

### High-Entropy Strings
- Random strings that appear to be secrets
- Base64 encoded credentials
- Hexadecimal strings of significant length
- UUID-like patterns in sensitive contexts

### Common Variable Names
Detection of suspicious values assigned to variables like:
- `password`
- `passwd`
- `secret`
- `key`
- `token`
- `auth`
- `credential`

## Language-Specific Patterns

### Python
- Django SECRET_KEY
- Flask SECRET_KEY
- Database URLs in Django settings

### JavaScript/Node.js
- JWT tokens
- API keys in package.json scripts
- Environment variable assignments

### Java
- JDBC connection strings
- Hibernate configurations
- Properties files with secrets

### PHP
- Database configuration arrays
- WordPress wp-config.php secrets

### Go
- Connection strings in code
- API keys in struct definitions

## Configuration Files

### Common Formats
- `.env` files with sensitive variables
- YAML configuration with credentials
- JSON config files
- INI files with passwords
- TOML configuration files

### DevOps Tools
- Docker compose files with secrets
- Kubernetes secrets (plain text)
- Ansible vault files (unencrypted)
- Terraform provider configurations

## Severity Levels

### CRITICAL
- Production API keys
- Database passwords
- Private keys with broad access
- Root credentials

### HIGH  
- Service-specific API keys
- Database connection strings
- SSL private keys
- Admin tokens

### MEDIUM
- Development/staging credentials
- Limited scope API keys
- Webhooks with authentication

### LOW
- Test credentials
- Development tokens
- Placeholder secrets (may be false positives)

## Best Practices for Prevention

### Development Environment
1. Use environment variables for all secrets
2. Never commit `.env` files with real values
3. Use secret management tools (HashiCorp Vault, AWS Secrets Manager)
4. Implement pre-commit hooks for secret scanning

### CI/CD Integration
1. Scan all branches and pull requests
2. Block builds when secrets are detected
3. Use dedicated CI/CD secret stores
4. Rotate secrets regularly

### Code Review Process
1. Include security review for all changes
2. Use automated secret detection in PRs
3. Educate team on secure coding practices
4. Maintain allow-lists for known false positives
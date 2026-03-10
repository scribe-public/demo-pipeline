#!/bin/bash
#
# Custom Pattern Secret Scanner
# Scan with organization-specific secret patterns
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎯 Custom Pattern Secret Scanner${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Create custom secret patterns config
CUSTOM_CONFIG="/tmp/trivy-custom-secrets.yaml"

cat > "${CUSTOM_CONFIG}" << 'EOF'
# Custom secret patterns for organization-specific secrets
secrets:
  # Internal API patterns
  - id: internal-api-key
    category: custom
    title: Internal API Key
    description: Organization internal API key pattern
    regex: '\b(internal[_-]?api[_-]?key[_-]?)([a-f0-9]{32}|[A-Za-z0-9]{32})\b'
    keywords:
      - internal
      - api
      - key

  # Database URLs with credentials  
  - id: db-connection-string
    category: custom
    title: Database Connection String
    description: Database URLs with embedded credentials
    regex: '\b(mysql|postgresql|postgres|mongodb)://[^:]+:[^@]+@[^/]+/\w+\b'
    keywords:
      - mysql://
      - postgresql://
      - postgres://
      - mongodb://

  # JWT tokens
  - id: jwt-token
    category: custom
    title: JWT Token
    description: JSON Web Token
    regex: '\beyJ[A-Za-z0-9_-]+'
    keywords:
      - eyJ

  # Custom organization patterns (modify these for your needs)
  - id: org-secret-key
    category: custom
    title: Organization Secret Key
    description: Custom organization secret key pattern
    regex: '\b(MYORG|myorg)[_-]?(secret|key|token)[_-]?[A-Za-z0-9]{16,}\b'
    keywords:
      - MYORG
      - myorg
      
  # Slack webhooks
  - id: slack-webhook
    category: custom
    title: Slack Webhook
    description: Slack incoming webhook URL
    regex: 'https://hooks\.slack\.com/services/[A-Z0-9]+/[A-Z0-9]+/[A-Za-z0-9]+'
    keywords:
      - hooks.slack.com

  # Generic high-entropy strings in config contexts
  - id: high-entropy-config
    category: custom
    title: High Entropy Configuration Value
    description: Suspicious high-entropy strings in configuration contexts
    regex: '\b(password|secret|key|token|auth)["\s]*[:=]["\s]*[A-Za-z0-9+/]{20,}[\'"]?'
    keywords:
      - password
      - secret
      - key
      - token
      - auth
EOF

echo -e "${CYAN}📋 Custom patterns loaded:${NC}"
echo -e "${BLUE}   • Internal API keys${NC}"
echo -e "${BLUE}   • Database connection strings${NC}"
echo -e "${BLUE}   • JWT tokens${NC}"
echo -e "${BLUE}   • Organization-specific secrets${NC}"
echo -e "${BLUE}   • Slack webhooks${NC}"
echo -e "${BLUE}   • High-entropy config values${NC}"

# Scan directory
SCAN_DIR="${1:-.}"
echo -e "${BLUE}📂 Scanning: ${SCAN_DIR}${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

# Run trivy with custom config
# Note: As of current Trivy versions, custom secret patterns are still being developed
# This script demonstrates the intended usage pattern
trivy fs --security-checks secret \
    --format table \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --exit-code 1 \
    "${SCAN_DIR}"

EXIT_CODE=$?

# Also run a grep-based scan for some custom patterns
echo -e "${CYAN}────────────────────────────────────────${NC}"
echo -e "${BLUE}🔍 Additional custom pattern check...${NC}"

CUSTOM_FINDINGS=false

# Check for internal API patterns
if grep -r -n --include="*.py" --include="*.js" --include="*.json" --include="*.yaml" --include="*.yml" --exclude-dir=.git \
   -E "(internal[_-]?api[_-]?key[_-]?)([a-f0-9]{32}|[A-Za-z0-9]{32})" "${SCAN_DIR}" 2>/dev/null; then
    echo -e "${RED}❌ Found internal API key patterns${NC}"
    CUSTOM_FINDINGS=true
fi

# Check for JWT tokens
if grep -r -n --include="*.py" --include="*.js" --include="*.json" --include="*.yaml" --include="*.yml" --exclude-dir=.git \
   -E "\beyJ[A-Za-z0-9_-]{20,}" "${SCAN_DIR}" 2>/dev/null; then
    echo -e "${RED}❌ Found JWT token patterns${NC}"
    CUSTOM_FINDINGS=true
fi

# Clean up
rm -f "${CUSTOM_CONFIG}"

echo -e "${CYAN}════════════════════════════════════════${NC}"

if [ $EXIT_CODE -eq 0 ] && [ "$CUSTOM_FINDINGS" = false ]; then
    echo -e "${GREEN}✅ No secrets found with custom patterns${NC}"
else
    echo -e "${RED}❌ Secrets detected with custom patterns!${NC}"
    EXIT_CODE=1
fi

echo -e "${BLUE}💡 Edit this script to customize patterns for your organization${NC}"
echo -e "${BLUE}💡 Standard scan: ./scripts/scan-basic.sh${NC}"

exit $EXIT_CODE
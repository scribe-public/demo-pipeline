#!/bin/bash
#
# CI/CD Optimized Secret Scanner  
# Designed for automated environments with proper exit codes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output (disabled in CI by default)
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
else
    RED='\033[0;31m'
    GREEN='\033[0;32m'  
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
fi

echo -e "${BLUE}🚀 CI/CD Secret Scanner${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}Installing Trivy...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Scan directory (default to current)
SCAN_DIR="${1:-.}"
echo -e "${BLUE}Scanning: ${SCAN_DIR}${NC}"

# Create output directory
mkdir -p ./security-reports

# Run scan with multiple formats for CI integration
echo -e "${BLUE}Running secret scan...${NC}"

# Table format for logs
trivy fs --security-checks secret \
    --format table \
    --severity HIGH,CRITICAL \
    --exit-code 2 \
    "${SCAN_DIR}" || SCAN_FAILED=true

# JSON format for automation
trivy fs --security-checks secret \
    --format json \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --output ./security-reports/secrets.json \
    "${SCAN_DIR}" || true

# SARIF format for GitHub Security tab
trivy fs --security-checks secret \
    --format sarif \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --output ./security-reports/secrets.sarif \
    "${SCAN_DIR}" || true

# Check if any secrets were found
if [ "$SCAN_FAILED" = "true" ]; then
    echo -e "${RED}FAILED: Secrets detected!${NC}"
    echo -e "${YELLOW}Reports generated in: ./security-reports/${NC}"
    
    # For GitHub Actions, set output
    if [ "$GITHUB_ACTIONS" = "true" ]; then
        echo "secrets-found=true" >> $GITHUB_OUTPUT
        echo "report-path=./security-reports/secrets.json" >> $GITHUB_OUTPUT
    fi
    
    exit 2
else
    echo -e "${GREEN}SUCCESS: No high/critical secrets found${NC}"
    
    # For GitHub Actions, set output
    if [ "$GITHUB_ACTIONS" = "true" ]; then
        echo "secrets-found=false" >> $GITHUB_OUTPUT
    fi
    
    exit 0
fi
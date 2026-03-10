#!/bin/bash
#
# Verbose Secret Scanner
# Detailed output with full information about detected secrets
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

echo -e "${BLUE}🔍 Verbose Secret Scanner${NC}"
echo -e "${CYAN}────────────────────────────────────────${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Scan directory
SCAN_DIR="${1:-.}"
echo -e "${BLUE}📂 Scanning directory: ${SCAN_DIR}${NC}"
echo -e "${BLUE}🕐 Start time: $(date)${NC}"
echo -e "${CYAN}────────────────────────────────────────${NC}"

# Show trivy version
echo -e "${BLUE}🔧 Trivy version:${NC}"
trivy --version
echo -e "${CYAN}────────────────────────────────────────${NC}"

# Run comprehensive scan with all severity levels
echo -e "${BLUE}🔍 Running comprehensive secret scan...${NC}"
echo -e "${YELLOW}⚠️  Including ALL severity levels (LOW, MEDIUM, HIGH, CRITICAL)${NC}"

trivy fs --security-checks secret \
    --format table \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --exit-code 1 \
    --slow \
    "${SCAN_DIR}"

EXIT_CODE=$?

echo -e "${CYAN}────────────────────────────────────────${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No secrets found!${NC}"
    echo -e "${GREEN}🎉 Repository appears clean${NC}"
else
    echo -e "${RED}❌ Secrets detected!${NC}"
    echo -e "${YELLOW}⚠️  IMMEDIATE ACTION REQUIRED:${NC}"
    echo -e "${YELLOW}   1. Remove secrets from code${NC}"
    echo -e "${YELLOW}   2. Rotate compromised credentials${NC}"
    echo -e "${YELLOW}   3. Check git history for exposure${NC}"
    echo -e "${YELLOW}   4. Update .gitignore to prevent future leaks${NC}"
fi

echo -e "${CYAN}────────────────────────────────────────${NC}"
echo -e "${BLUE}🕐 End time: $(date)${NC}"
echo -e "${BLUE}💡 For automated processing: ./scripts/scan-json.sh${NC}"
echo -e "${BLUE}💡 For CI/CD integration: ./scripts/scan-ci.sh${NC}"

exit $EXIT_CODE
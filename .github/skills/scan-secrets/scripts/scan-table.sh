#!/bin/bash
#
# Table Format Secret Scanner
# Clean, human-readable table output
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

echo -e "${BLUE}📋 Table Format Secret Scanner${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Scan directory
SCAN_DIR="${1:-.}"
SEVERITY="${2:-HIGH,CRITICAL}"

echo -e "${BLUE}📂 Scanning: ${SCAN_DIR}${NC}"
echo -e "${BLUE}🎯 Severity levels: ${SEVERITY}${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"

# Run trivy secret scan with clean table format
trivy fs --security-checks secret \
    --format table \
    --severity "${SEVERITY}" \
    --exit-code 1 \
    "${SCAN_DIR}"

EXIT_CODE=$?

echo -e "${CYAN}════════════════════════════════════════${NC}"

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No secrets found at ${SEVERITY} severity levels${NC}"
else
    echo -e "${RED}❌ Secrets detected!${NC}"
    echo -e "${YELLOW}📋 Summary recommendations:${NC}"
    echo -e "${YELLOW}   • Remove hardcoded secrets immediately${NC}"
    echo -e "${YELLOW}   • Use environment variables or secret managers${NC}"
    echo -e "${YELLOW}   • Rotate any exposed credentials${NC}"
    echo -e "${YELLOW}   • Add patterns to .gitignore${NC}"
fi

echo -e "${BLUE}💡 All severities: $0 \"${SCAN_DIR}\" \"LOW,MEDIUM,HIGH,CRITICAL\"${NC}"
echo -e "${BLUE}💡 JSON format: ./scripts/scan-json.sh \"${SCAN_DIR}\"${NC}"

exit $EXIT_CODE
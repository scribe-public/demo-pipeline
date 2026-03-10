#!/bin/bash
#
# Basic Trivy Secret Scanner
# Scans current directory for secrets with default settings
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Starting basic secret scan...${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Default scan directory
SCAN_DIR="${1:-.}"

echo -e "${BLUE}📂 Scanning directory: ${SCAN_DIR}${NC}"

# Run trivy secret scan
trivy fs --security-checks secret \
    --format table \
    --severity HIGH,CRITICAL \
    --quiet \
    "${SCAN_DIR}"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No high/critical secrets found!${NC}"
else
    echo -e "${RED}❌ Secrets detected! Please review and remediate.${NC}"
fi

echo -e "${BLUE}💡 For more detailed output, use: ./scripts/scan-verbose.sh${NC}"
echo -e "${BLUE}💡 For CI/CD use: ./scripts/scan-ci.sh${NC}"

exit $EXIT_CODE
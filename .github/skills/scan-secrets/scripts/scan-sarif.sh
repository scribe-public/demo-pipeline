#!/bin/bash
#
# SARIF Output Secret Scanner  
# Outputs results in SARIF format for GitHub Security tab integration
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📊 SARIF Secret Scanner${NC}" >&2

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}" >&2
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Scan directory
SCAN_DIR="${1:-.}"
OUTPUT_FILE="${2:-secrets-report.sarif}"

echo -e "${BLUE}📂 Scanning: ${SCAN_DIR}${NC}" >&2
echo -e "${BLUE}💾 SARIF output: ${OUTPUT_FILE}${NC}" >&2

# Run trivy secret scan with SARIF output
trivy fs --security-checks secret \
    --format sarif \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --output "${OUTPUT_FILE}" \
    "${SCAN_DIR}"

EXIT_CODE=$?

# Provide summary to stderr
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ SARIF report generated: ${OUTPUT_FILE}${NC}" >&2
    echo -e "${BLUE}📤 Upload to GitHub Security tab with:${NC}" >&2
    echo -e "${BLUE}   GitHub Actions: upload-sarif action${NC}" >&2
else
    echo -e "${RED}❌ Secrets found - SARIF report: ${OUTPUT_FILE}${NC}" >&2
fi

# Show file info
if [ -f "${OUTPUT_FILE}" ]; then
    SIZE=$(du -h "${OUTPUT_FILE}" | cut -f1)
    echo -e "${BLUE}📄 File size: ${SIZE}${NC}" >&2
fi

echo -e "${BLUE}💡 GitHub Security integration: https://docs.github.com/en/code-security/code-scanning/integrating-with-code-scanning/sarif-support-for-code-scanning${NC}" >&2

exit $EXIT_CODE
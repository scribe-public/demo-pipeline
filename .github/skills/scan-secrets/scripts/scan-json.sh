#!/bin/bash
#
# JSON Output Secret Scanner
# Outputs results in JSON format for automation and parsing
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 JSON Secret Scanner${NC}" >&2

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}" >&2
    "${SCRIPT_DIR}/install-trivy.sh"
fi

# Scan directory
SCAN_DIR="${1:-.}"
OUTPUT_FILE="${2:-secrets-report.json}"

echo -e "${BLUE}📂 Scanning: ${SCAN_DIR}${NC}" >&2
echo -e "${BLUE}💾 Output file: ${OUTPUT_FILE}${NC}" >&2

# Run trivy secret scan with JSON output
trivy fs --security-checks secret \
    --format json \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --output "${OUTPUT_FILE}" \
    "${SCAN_DIR}"

EXIT_CODE=$?

# Also output to stdout if no output file specified in args
if [ "$2" = "" ]; then
    echo -e "${BLUE}📄 JSON Output:${NC}" >&2
    cat "${OUTPUT_FILE}"
fi

# Provide summary to stderr
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ Scan complete - results saved to ${OUTPUT_FILE}${NC}" >&2
else
    echo -e "${RED}❌ Secrets found - results saved to ${OUTPUT_FILE}${NC}" >&2
fi

echo -e "${BLUE}💡 Process with: jq '.Results[]?.Secrets[]?' ${OUTPUT_FILE}${NC}" >&2

exit $EXIT_CODE
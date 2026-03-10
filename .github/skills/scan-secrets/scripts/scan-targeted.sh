#!/bin/bash
#
# Targeted Trivy Secret Scanner
# Scans specific files or directories for secrets
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if target path provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Usage: $0 <target-path>${NC}"
    echo -e "${BLUE}💡 Example: $0 src/config/database.py${NC}"
    echo -e "${BLUE}💡 Example: $0 src/api/${NC}"
    exit 1
fi

TARGET="$1"

if [ ! -e "$TARGET" ]; then
    echo -e "${RED}❌ Target does not exist: $TARGET${NC}"
    exit 1
fi

echo -e "${BLUE}🎯 Starting targeted secret scan...${NC}"

# Check if trivy is installed
if ! command -v trivy &> /dev/null; then
    echo -e "${YELLOW}⚠️  Trivy not found. Installing...${NC}"
    "${SCRIPT_DIR}/install-trivy.sh"
fi

echo -e "${BLUE}📂 Scanning target: ${TARGET}${NC}"

# Determine if target is file or directory
if [ -f "$TARGET" ]; then
    echo -e "${BLUE}📄 Single file scan${NC}"
    SCAN_TYPE="file"
else
    echo -e "${BLUE}📁 Directory scan${NC}"
    SCAN_TYPE="directory"
fi

# Run trivy secret scan
echo -e "${BLUE}🔍 Scanning for secrets...${NC}"

trivy fs --security-checks secret \
    --format table \
    --severity LOW,MEDIUM,HIGH,CRITICAL \
    --exit-code 1 \
    "${TARGET}"

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ No secrets found in: ${TARGET}${NC}"
else
    echo -e "${RED}❌ Secrets detected in: ${TARGET}${NC}"
    echo -e "${YELLOW}⚠️  Please review and remediate immediately!${NC}"
fi

echo -e "${BLUE}💡 For JSON output: ./scripts/scan-json.sh \"${TARGET}\"${NC}"
echo -e "${BLUE}💡 For verbose output: ./scripts/scan-verbose.sh \"${TARGET}\"${NC}"

exit $EXIT_CODE
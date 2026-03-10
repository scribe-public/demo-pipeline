#!/bin/bash
#
# Trivy Installation Script
# Automatically installs Trivy security scanner
#

set -e

# Colors for output
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📦 Installing Trivy security scanner...${NC}"

# Detect OS
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case $ARCH in
    x86_64) ARCH="amd64" ;;
    aarch64) ARCH="arm64" ;;
    arm64) ARCH="arm64" ;;
    *) echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}"; exit 1 ;;
esac

echo -e "${BLUE}🖥️  Detected OS: $OS, Architecture: $ARCH${NC}"

# Check if running in CI
if [ "$CI" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    echo -e "${YELLOW}🤖 CI environment detected${NC}"
    USE_SUDO=""
else
    # Check if sudo is needed and available
    if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
        USE_SUDO="sudo"
        echo -e "${YELLOW}🔐 Will use sudo for installation${NC}"
    else
        USE_SUDO=""
    fi
fi

# Install based on OS
case $OS in
    linux)
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu
            echo -e "${BLUE}📥 Installing via apt...${NC}"
            $USE_SUDO apt-get update -qq
            $USE_SUDO apt-get install -y wget apt-transport-https gnupg lsb-release
            wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | $USE_SUDO apt-key add -
            echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | $USE_SUDO tee -a /etc/apt/sources.list.d/trivy.list
            $USE_SUDO apt-get update -qq
            $USE_SUDO apt-get install -y trivy
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS/Fedora
            echo -e "${BLUE}📥 Installing via yum...${NC}"
            $USE_SUDO yum install -y https://github.com/aquasecurity/trivy/releases/latest/download/trivy_Linux-64bit.rpm
        elif command -v apk &> /dev/null; then
            # Alpine
            echo -e "${BLUE}📥 Installing via apk...${NC}"
            $USE_SUDO apk add --no-cache trivy
        else
            # Generic Linux - download binary
            echo -e "${BLUE}📥 Installing binary directly...${NC}"
            LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4)
            wget -q "https://github.com/aquasecurity/trivy/releases/download/${LATEST}/trivy_${LATEST#v}_Linux-${ARCH}.tar.gz"
            tar zxf "trivy_${LATEST#v}_Linux-${ARCH}.tar.gz"
            $USE_SUDO mv trivy /usr/local/bin/
            rm "trivy_${LATEST#v}_Linux-${ARCH}.tar.gz"
        fi
        ;;
    darwin)
        # macOS
        if command -v brew &> /dev/null; then
            echo -e "${BLUE}📥 Installing via Homebrew...${NC}"
            brew install trivy
        else
            echo -e "${BLUE}📥 Installing binary directly...${NC}"
            LATEST=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4)
            wget -q "https://github.com/aquasecurity/trivy/releases/download/${LATEST}/trivy_${LATEST#v}_macOS-${ARCH}.tar.gz"
            tar zxf "trivy_${LATEST#v}_macOS-${ARCH}.tar.gz"
            $USE_SUDO mv trivy /usr/local/bin/
            rm "trivy_${LATEST#v}_macOS-${ARCH}.tar.gz"
        fi
        ;;
    *)
        echo -e "${RED}❌ Unsupported OS: $OS${NC}"
        exit 1
        ;;
esac

# Verify installation
if command -v trivy &> /dev/null; then
    VERSION=$(trivy version | head -n1)
    echo -e "${GREEN}✅ Trivy installed successfully!${NC}"
    echo -e "${GREEN}📋 Version: $VERSION${NC}"
else
    echo -e "${RED}❌ Installation failed!${NC}"
    exit 1
fi

# Update database
echo -e "${BLUE}🔄 Updating vulnerability database...${NC}"
trivy image --download-db-only

echo -e "${GREEN}🎉 Trivy is ready to use!${NC}"
echo -e "${BLUE}💡 Run: trivy --help for usage information${NC}"
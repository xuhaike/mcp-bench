#!/bin/bash

# MCP-Bench Quick Setup Script
# This script automates the environment setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect if running in conda
check_conda() {
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        log_info "Detected conda environment: $CONDA_DEFAULT_ENV"
        return 0
    else
        return 1
    fi
}

# Main setup
main() {
    echo "╔══════════════════════════════════════════╗"
    echo "║   MCP-Bench Quick Setup Script          ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""

    # Check if in correct directory
    if [ ! -f "requirements.txt" ]; then
        log_error "Please run this script from the mcp-bench root directory"
        exit 1
    fi

    # Step 1: Check Python version
    log_info "Checking Python version..."
    PYTHON_VERSION=$(python --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
    PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

    if [ "$PYTHON_MAJOR" -lt 3 ] || ([ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 10 ]); then
        log_error "Python 3.10+ required. Current version: $PYTHON_VERSION"
        log_info "Please install Python 3.10 or higher, or activate a compatible conda environment"
        exit 1
    fi
    log_success "Python $PYTHON_VERSION detected"

    # Step 2: Install Python dependencies
    log_info "Installing Python dependencies..."
    pip install -r requirements.txt
    log_success "Python dependencies installed"

    # Step 3: Install MCP servers
    log_info "Installing MCP servers and Node.js dependencies..."
    cd mcp_servers

    # Check if we should use sudo
    if check_conda; then
        log_warning "Running in conda environment. Install script will use sudo for system packages."
        log_info "You may be prompted for your password."
    fi

    sudo ./install.sh
    cd ..
    log_success "MCP servers installed"

    # Step 4: Fix permissions
    log_info "Fixing file permissions..."
    sudo chown -R $USER:$USER mcp_servers
    log_success "Permissions fixed"

    # Step 5: Install editable packages for mcpbench environment
    log_info "Installing editable MCP server packages..."
    if [ -d "mcp_servers/unit-converter-mcp" ]; then
        pip install -e mcp_servers/unit-converter-mcp
    fi
    if [ -d "mcp_servers/time-mcp" ]; then
        pip install -e mcp_servers/time-mcp
    fi
    log_success "Editable packages installed"

    # Step 6: Environment file check
    echo ""
    log_info "Checking environment configuration..."

    if [ ! -f "mcp_servers/.env" ]; then
        log_warning "No .env file found. Creating template..."
        cat > mcp_servers/.env << 'EOF'
# Add your LLM provider API key here
export OPENROUTER_API_KEY="your-api-key-here"
# Or use OpenAI directly
# export OPENAI_API_KEY="your-api-key-here"
EOF
        log_success "Created mcp_servers/.env template"
    fi

    if [ -f "mcp_servers/api_key" ]; then
        if grep -q "YOUR_KEY_HERE" mcp_servers/api_key; then
            log_warning "API keys in mcp_servers/api_key need to be configured"
            log_info "Edit mcp_servers/api_key and replace YOUR_KEY_HERE with actual API keys"
        fi
    fi

    # Step 7: Verification
    echo ""
    log_info "Verifying installation..."

    log_info "Testing MCP server collection..."
    if python ./utils/collect_mcp_info.py > /tmp/mcp_test.log 2>&1; then
        SERVERS_CONNECTED=$(grep "servers connected" /tmp/mcp_test.log | tail -1 | awk '{print $1}')
        TOOLS_DISCOVERED=$(grep "Total tools discovered:" /tmp/mcp_test.log | tail -1 | awk '{print $4}')
        log_success "MCP servers test passed: $SERVERS_CONNECTED servers, $TOOLS_DISCOVERED tools"
    else
        log_warning "MCP server test had issues. Check /tmp/mcp_test.log for details"
    fi

    # Final message
    echo ""
    echo "╔══════════════════════════════════════════╗"
    echo "║        Setup Complete!                   ║"
    echo "╚══════════════════════════════════════════╝"
    echo ""
    log_success "MCP-Bench is ready to use!"
    echo ""
    log_info "Next steps:"
    echo "  1. Configure API keys in mcp_servers/api_key"
    echo "  2. Set your LLM API key in mcp_servers/.env"
    echo "  3. Source environment: source mcp_servers/.env"
    echo "  4. Run benchmarks: python benchmark/runner.py"
    echo ""
    log_info "For troubleshooting, see SETUP.md"
}

# Run main function
main "$@"

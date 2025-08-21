#!/bin/bash
# Template build script for static binaries
# Customize the build_tool() function for your specific tools

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging functions
log_step() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ERROR:${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] WARNING:${NC} $1"
}

# Setup build environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR=$(mktemp -d)
INSTALL_DIR="${SCRIPT_DIR}/static_binaries"

# Cleanup on exit
cleanup() {
    log_step "Cleaning up build directory..."
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

# Create installation directory
mkdir -p "$INSTALL_DIR"

# Install build dependencies
install_dependencies() {
    log_step "Installing build dependencies..."
    
    if ! command -v go &> /dev/null; then
        log_error "Go is not installed. Please install Go first."
        exit 1
    fi
    
    # Add your project-specific dependencies here
    sudo apt-get update
    sudo apt-get install -y \
        build-essential \
        git \
        pkg-config \
        # Add more dependencies as needed
}

# Generic tool builder function
build_tool() {
    local tool_name=$1
    local repo_url=$2
    local build_commands=$3
    
    log_step "Building $tool_name from $repo_url..."
    
    cd "$BUILD_DIR"
    git clone --depth 1 "$repo_url" "$tool_name"
    cd "$tool_name"
    
    # Export common build variables
    export CGO_ENABLED=0
    export GOOS=linux
    export GOARCH=amd64
    export INSTALL_DIR="$INSTALL_DIR"
    
    # Execute build commands
    eval "$build_commands"
    
    # Verify the binary exists
    if [ ! -f "$INSTALL_DIR/$tool_name" ]; then
        log_error "Failed to build $tool_name"
        return 1
    fi
    
    # Make executable
    chmod +x "$INSTALL_DIR/$tool_name"
    
    log_step "Successfully built $tool_name"
}

# Main build process
main() {
    log_step "Starting static binary build process..."
    
    # Install dependencies
    install_dependencies
    
    # Example: Build your tools here
    # Customize these for your specific tools
    
    # build_tool "tool-name" "https://github.com/org/repo" "build commands"
    
    # Example for a Go project:
    # build_tool "mytool" "https://github.com/myorg/mytool" \
    #     "go build -ldflags '-s -w -extldflags \"-static\"' -o \$INSTALL_DIR/mytool ./cmd/mytool"
    
    # Example for a Make-based project:
    # build_tool "anothertool" "https://github.com/org/anothertool" \
    #     "make static && cp bin/anothertool \$INSTALL_DIR/"
    
    log_step "Build complete! Binaries are in: $INSTALL_DIR"
    
    # List built binaries
    log_step "Built binaries:"
    ls -la "$INSTALL_DIR"
    
    # Verify static linking
    log_step "Verifying static linking:"
    for binary in "$INSTALL_DIR"/*; do
        if [ -f "$binary" ] && [ -x "$binary" ]; then
            echo -n "$(basename "$binary"): "
            if ldd "$binary" 2>&1 | grep -q "not a dynamic executable"; then
                echo "✓ statically linked"
            else
                echo "⚠ may have dynamic dependencies"
            fi
        fi
    done
}

# Run main function
main "$@"
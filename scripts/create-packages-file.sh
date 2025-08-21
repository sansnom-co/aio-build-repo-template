#!/bin/bash

# Script to create APT Packages file from GitHub releases

REPO="${1:-owner/repo}"
OUTPUT_FILE="${2:-Packages}"
PACKAGE_NAME="${PACKAGE_NAME:-my-tools}"

echo "Creating Packages file for $REPO..."

# Clear output file
> "$OUTPUT_FILE"

# Use curl to avoid authentication issues
RELEASES=$(curl -s "https://api.github.com/repos/$REPO/releases")
echo "Found $(echo "$RELEASES" | jq '. | length') releases"

# Get all releases and create package entries
echo "$RELEASES" | jq -r '.[] | .assets[] | select(.name | endswith(".deb")) | "\(.name)|\(.browser_download_url)|\(.size)"' | while IFS='|' read -r name url size; do
    echo "Processing: $name"
    
    # Skip if any field is empty
    if [ -z "$name" ] || [ -z "$url" ] || [ -z "$size" ]; then
        continue
    fi
    
    # Extract version from filename
    version=$(echo "$name" | sed -n "s/${PACKAGE_NAME}_\\(.*\\)_amd64\\.deb/\\1/p")
    
    if [ -z "$version" ]; then
        echo "Warning: Could not extract version from $name"
        continue
    fi
    
    # Create package entry
    {
        echo "Package: $PACKAGE_NAME"
        echo "Version: $version"
        echo "Architecture: amd64"
        echo "Maintainer: ${MAINTAINER_EMAIL:-maintainer@example.com}"
        echo "Depends: ca-certificates"
        echo "Section: utils"
        echo "Priority: optional"
        echo "Size: $size"
        echo "Filename: $url"
        echo "Description: Statically linked tools"
        echo " This package contains statically linked binaries."
        echo ""
    } >> "$OUTPUT_FILE"
done

echo "Created Packages file with $(grep -c "^Package:" "$OUTPUT_FILE") entries"
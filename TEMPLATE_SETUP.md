# Template Setup Guide

## Step-by-Step Setup

### 1. Create Your Repository

1. Click "Use this template" on GitHub
2. Name your repository (e.g., `my-static-tools`)
3. Clone your new repository

### 2. Generate GPG Key

```bash
# Generate a new GPG key
gpg --gen-key

# Export the private key
gpg --armor --export-secret-keys your-email@example.com > private.key

# Get the key ID
gpg --list-secret-keys --keyid-format LONG
```

### 3. Add GitHub Secrets

Go to Settings → Secrets → Actions and add:

- `GPG_PRIVATE_KEY`: Contents of private.key file
- `GPG_PASSPHRASE`: Your GPG key passphrase

### 4. Configure Your Tools

Edit the build script to add your tools. For example, to add `yq`:

```bash
# In build_static_tools.sh, add to main():
build_tool "yq" "https://github.com/mikefarah/yq" \
    "go build -ldflags '-s -w -extldflags \"-static\"' -o \$INSTALL_DIR/yq ."
```

### 5. Update Package Name

In both workflow files, change:
```yaml
env:
  PACKAGE_NAME: your-tools-name
```

### 6. Test Locally

```bash
# Make script executable
chmod +x build_static_tools.sh

# Run build
./build_static_tools.sh

# Check binaries
ls -la static_binaries/
ldd static_binaries/*  # Should show "not a dynamic executable"
```

### 7. Create First Release

```bash
# Commit your changes
git add -A
git commit -m "Initial setup"
git push

# Create and push a tag
git tag v$(date +%y.%m).0
git push origin v$(date +%y.%m).0
```

### 8. Enable GitHub Pages

After the workflows run:
1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: gh-pages / (root)
4. Save

Your APT repository will be available at:
`https://YOUR-USERNAME.github.io/YOUR-REPO/`

## Example: Adding Multiple Tools

```bash
# In build_static_tools.sh
main() {
    log_step "Starting static binary build process..."
    
    install_dependencies
    
    # Build multiple tools
    build_tool "tool1" "https://github.com/org/tool1" \
        "make static && cp bin/tool1 \$INSTALL_DIR/"
    
    build_tool "tool2" "https://github.com/org/tool2" \
        "cargo build --release --target x86_64-unknown-linux-musl && cp target/x86_64-unknown-linux-musl/release/tool2 \$INSTALL_DIR/"
    
    build_tool "tool3" "https://github.com/org/tool3" \
        "go build -ldflags '-s -w -extldflags \"-static\"' -o \$INSTALL_DIR/tool3 ./cmd/tool3"
    
    log_step "Build complete!"
}
```

## Verification

After setup, users can install your package:

```bash
# They'll run:
sudo apt update
sudo apt install your-package-name

# Verify installation
which tool1 tool2 tool3
```
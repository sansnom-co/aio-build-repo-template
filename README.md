# All in One Binary APT Repository Template

**A complete template for building, packaging, and distributing static binaries with GitHub Actions.**

This repository provides a production-ready framework for:

* **Building**: Generic build system supporting Go, C/C++, Rust, and Make-based projects.
* **Packaging**: Automatic `.deb` and `.rpm` creation with GPG signing.
* **Releasing**: GitHub Actions workflows for CI/CD, artifact publishing, and GitHub Releases.
* **APT Repository Hosting**: Fully automated Debian/Ubuntu APT repo published via GitHub Pages.
* **Security**: Static linking verification, vulnerability scans (Trivy), and signed packages.

### Why use this template?

* No infrastructure cost — everything runs on GitHub.
* Professional distribution — packages install via standard `apt install`.
* Secure and maintainable — GPG signing, reproducible builds, vulnerability scanning.
* Flexible — drop in your project, customise build commands, and you’re done.

### Features

- Build static binaries from any source repository
- Automatic .deb and .rpm package creation
- GPG signing for security
- APT repository hosted on GitHub Pages
- Security scanning with Trivy
- GitHub Actions automation
- Support for both APT 2.x and APT 3.0 formats
- CalVer versioning (YY.MM.patch)

## Quick Start

### 1. Use This Template

Click "Use this template" on GitHub to create a new repository based on this template.

### 2. Configure Your Project

Edit `config/tools.yaml` to define your tools:

```yaml
project:
  name: "my-tools"
  description: "My collection of tools"
  maintainer: "Your Name <your@email.com>"
  vendor: "your-org"

tools:
  - name: kubectl
    repo: https://github.com/kubernetes/kubernetes
    build: |
      # Your build commands here
      make WHAT=cmd/kubectl
      cp _output/bin/kubectl $INSTALL_DIR/
```

### 3. Customize Build Script

Edit `build_static_tools.sh` to add your specific build logic in the `main()` function:

```bash
# Example: Build a Go tool
build_tool "mytool" "https://github.com/org/mytool" \
    "go build -ldflags '-s -w -extldflags \"-static\"' -o \$INSTALL_DIR/mytool ./cmd/mytool"
```

### 4. Set Up GitHub Secrets

Go to Settings → Secrets and add:

- `GPG_PRIVATE_KEY`: Your GPG private key for signing packages
- `GPG_PASSPHRASE`: Passphrase for the GPG key

To generate a GPG key:
```bash
gpg --gen-key
gpg --armor --export-secret-keys your-email@example.com > private.key
# Copy contents of private.key to GPG_PRIVATE_KEY secret
```

### 5. Configure GitHub Pages

1. Go to Settings → Pages
2. Source: Deploy from a branch
3. Branch: `gh-pages` / `/ (root)`
4. Save

### 6. Update Environment Variables

In `.github/workflows/build-release.yml` and `.github/workflows/publish-apt-repo.yml`:

```yaml
env:
  PACKAGE_NAME: your-package-name  # Change this
```

### 7. Create Your First Release

```bash
git tag v$(date +%y.%m).0
git push origin v$(date +%y.%m).0
```

This will trigger the build workflow and create your APT repository.

## Workflow Overview

1. **Build Workflow** (`build-release.yml`)
   - Triggered on tags and main branch pushes
   - Builds static binaries
   - Scans for vulnerabilities
   - Creates .deb and .rpm packages
   - Signs packages (for releases)
   - Publishes to GitHub Releases

2. **APT Repository Workflow** (`publish-apt-repo.yml`)
   - Triggered after successful build
   - Creates APT repository metadata
   - Publishes to GitHub Pages
   - Updates repository index

## Directory Structure

```
.
├── .github/
│   └── workflows/
│       ├── build-release.yml      # Main build workflow
│       └── publish-apt-repo.yml   # APT repository publisher
├── scripts/
│   ├── create-packages-file.sh    # Generate Packages file
│   ├── create-release-file.sh     # Generate Release file
│   └── create-repo-index.sh       # Generate HTML index
├── config/
│   └── tools.yaml                 # Tool configuration
├── build_static_tools.sh          # Main build script
└── static_binaries/               # Output directory (gitignored)
```

## Customization Guide

### Adding New Tools

1. Update `build_static_tools.sh` with build commands
2. Ensure static linking flags are used:
   - Go: `CGO_ENABLED=0` and `-extldflags '-static'`
   - C/C++: `-static` flag
   - Rust: `--target x86_64-unknown-linux-musl`

### Changing Package Metadata

Update workflow files:
- Package name: `PACKAGE_NAME` environment variable
- Maintainer: `--maintainer` flag in FPM commands
- Description: `--description` flag in FPM commands

### Custom Repository Structure

Edit `scripts/create-repo-index.sh` to customize the landing page.

## Installation Instructions for Users

Once your repository is set up, users can install your packages:

```bash
# Add GPG key
wget -O- https://YOUR-USERNAME.github.io/YOUR-REPO/public_key.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/YOUR-PACKAGE-keyring.gpg

# Add repository
echo "deb [signed-by=/usr/share/keyrings/YOUR-PACKAGE-keyring.gpg] \
  https://YOUR-USERNAME.github.io/YOUR-REPO stable main" | \
  sudo tee /etc/apt/sources.list.d/YOUR-PACKAGE.list

# Install
sudo apt update
sudo apt install YOUR-PACKAGE
```

## Tips

1. **Static Linking Verification**: Use `ldd` to verify binaries are statically linked
2. **Version Format**: Tags should be `vYY.MM.PATCH` (e.g., `v24.12.0`)
3. **Development Builds**: Pushes to main create dev releases
4. **GPG Key**: Keep your private key secure, never commit it

---

<p align="center">Made with ❤️ and ☕ in London</p>

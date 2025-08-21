#!/bin/bash

# Create the index.html file for the GitHub Pages repository
# Customize the variables below for your project

PACKAGE_NAME="${PACKAGE_NAME:-my-tools}"
PROJECT_NAME="${PROJECT_NAME:-My Tools}"
PROJECT_DESCRIPTION="${PROJECT_DESCRIPTION:-Collection of statically linked tools}"
GITHUB_REPO="${GITHUB_REPOSITORY:-owner/repo}"

cat > index.html << ENDHTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$PROJECT_NAME - Debian Repository</title>
    <style>
        :root {
            --bg-color: #0d1117;
            --text-color: #c9d1d9;
            --code-bg: #161b22;
            --border-color: #30363d;
            --header-color: #ffffff;
        }
        body {
            background-color: var(--bg-color);
            color: var(--text-color);
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif;
            font-size: 16px;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        h1, h2 {
            color: var(--header-color);
            border-bottom: 1px solid var(--border-color);
            padding-bottom: 0.3em;
        }
        h3 {
            color: var(--header-color);
            margin-top: 1.5em;
            margin-bottom: 0.5em;
        }
        code {
            background-color: var(--code-bg);
            padding: 0.2em 0.4em;
            border-radius: 3px;
            font-size: 14px;
        }
        pre {
            background-color: var(--code-bg);
            padding: 16px;
            overflow-x: auto;
            border-radius: 6px;
            border: 1px solid var(--border-color);
            font-size: 14px;
        }
        pre code {
            background-color: transparent;
            padding: 0;
            font-size: 14px;
        }
        a {
            color: #58a6ff;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        table {
            border-collapse: collapse;
            width: 100%;
            margin: 1em 0;
        }
        th, td {
            border: 1px solid var(--border-color);
            padding: 0.6em 1em;
            text-align: left;
        }
        th {
            background-color: var(--code-bg);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$PROJECT_NAME Debian Repository</h1>
        
        <p>$PROJECT_DESCRIPTION</p>
        
        <h2>Quick Installation</h2>
        
        <h3>For APT 2.x (Traditional format)</h3>
        <pre><code># Add the GPG key
wget -O- https://${GITHUB_REPO#*/}.github.io/${GITHUB_REPO##*/}/public_key.asc | \\
  sudo gpg --dearmor -o /usr/share/keyrings/${PACKAGE_NAME}-keyring.gpg

# Add the repository
echo "deb [signed-by=/usr/share/keyrings/${PACKAGE_NAME}-keyring.gpg] \\
  https://${GITHUB_REPO#*/}.github.io/${GITHUB_REPO##*/} stable main" | \\
  sudo tee /etc/apt/sources.list.d/${PACKAGE_NAME}.list

# Update and install
sudo apt update
sudo apt install $PACKAGE_NAME</code></pre>
        
        <h3>For APT 3.0+ (deb822 format)</h3>
        <pre><code># Add the GPG key
wget -O- https://${GITHUB_REPO#*/}.github.io/${GITHUB_REPO##*/}/public_key.asc | \\
  sudo gpg --dearmor -o /usr/share/keyrings/${PACKAGE_NAME}-keyring.gpg

# Add the repository using deb822 format
sudo tee /etc/apt/sources.list.d/${PACKAGE_NAME}.sources << EOF
Types: deb
URIs: https://${GITHUB_REPO#*/}.github.io/${GITHUB_REPO##*/}
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/${PACKAGE_NAME}-keyring.gpg
EOF

# Update and install
sudo apt update
sudo apt install $PACKAGE_NAME</code></pre>
        
        <h2>Repository Details</h2>
        
        <ul>
            <li><strong>Suite</strong>: stable</li>
            <li><strong>Component</strong>: main</li>
            <li><strong>Architecture</strong>: amd64</li>
        </ul>
        
        <h2>Links</h2>
        
        <ul>
            <li><a href="https://github.com/$GITHUB_REPO">GitHub Repository</a></li>
            <li><a href="https://github.com/$GITHUB_REPO/releases">Releases</a></li>
            <li><a href="public_key.asc">GPG Public Key</a></li>
        </ul>
        
        <hr>
        
        <p><small>Updated automatically via GitHub Actions</small></p>
    </div>
</body>
</html>
ENDHTML
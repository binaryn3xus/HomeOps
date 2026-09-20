#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
DOTNET_VERSION="10.0"
HERMES_DATA="/opt/data"
DOTNET_ROOT="$HERMES_DATA/dotnet"

echo "🌿 Hermes Clean Setup Starting..."

# 1. Ensure directories exist
mkdir -p "$DOTNET_ROOT"
mkdir -p "$HERMES_DATA/profiles"
mkdir -p "$HERMES_DATA/profiles/cortana"
mkdir -p "$HERMES_DATA/profiles/skippy"
mkdir -p "$HERMES_DATA/profiles/networker"
mkdir -p "$HERMES_DATA/bin"

# Git uses GIT_ASKPASS for HTTPS credentials. The helper reads the token only
# at invocation time, so credentials are not written to git config, remotes,
# or the persistent volume.
install -m 0700 /tmp/scripts/git-askpass.sh "$HERMES_DATA/bin/git-askpass"
git config --global credential.helper ""
git config --global credential.useHttpPath true

# 2. Master Config & Souls Setup
if [ -f "/tmp/config-source/config.yaml" ]; then
    echo "📝 Synchronizing master configuration..."
    cp /tmp/config-source/config.yaml "$HERMES_DATA/config.yaml"
fi

if [ -d "/tmp/souls" ]; then
    echo "🧠 Synchronizing agent personas (Souls)..."
    [ -f "/tmp/souls/cortana.md" ] && cp /tmp/souls/cortana.md "$HERMES_DATA/profiles/cortana/SOUL.md"
    [ -f "/tmp/souls/skippy.md" ] && cp /tmp/souls/skippy.md "$HERMES_DATA/profiles/skippy/SOUL.md" && cp /tmp/souls/skippy.md "$HERMES_DATA/SOUL.md"
    [ -f "/tmp/souls/superintendent.md" ] && cp /tmp/souls/superintendent.md "$HERMES_DATA/profiles/networker/SOUL.md"
fi

# Normalize PVC ownership so unprivileged Hermes (uid 10000) can manage state.db and sqlite stores
echo "🔒 Normalizing PVC file ownership..."
chown -R 10000:10000 "$HERMES_DATA"

# 3. .NET SDK Installation (Persistent)
if [ ! -x "$DOTNET_ROOT/dotnet" ]; then
    echo "🚀 Installing .NET SDK..."
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel "$DOTNET_VERSION" || \
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel STS
fi

# 3b. SRE & Development Tooling (kubectl, talosctl, gh)
BIN_DIR="$HERMES_DATA/bin"
mkdir -p "$BIN_DIR"

if [ ! -x "$BIN_DIR/kubectl" ]; then
    echo "📦 Installing kubectl..."
    curl -fsSL -o "$BIN_DIR/kubectl" "https://dl.k8s.io/release/v1.35.3/bin/linux/amd64/kubectl"
    chmod +x "$BIN_DIR/kubectl"
fi

if [ ! -x "$BIN_DIR/talosctl" ]; then
    echo "📦 Installing talosctl..."
    curl -fsSL -o "$BIN_DIR/talosctl" "https://github.com/siderolabs/talos/releases/download/v1.14.1/talosctl-linux-amd64"
    chmod +x "$BIN_DIR/talosctl"
fi

if [ ! -x "$BIN_DIR/gh" ]; then
    echo "📦 Installing GitHub CLI (gh)..."
    curl -fsSL "https://github.com/cli/cli/releases/download/v2.101.0/gh_2.101.0_linux_amd64.tar.gz" | tar -xz -C /tmp
    cp /tmp/gh_2.101.0_linux_amd64/bin/gh "$BIN_DIR/gh"
    chmod +x "$BIN_DIR/gh"
    rm -rf /tmp/gh_*
fi

# 3c. Talos Configuration Setup
if [ -n "${TALOS_CONFIG:-}" ]; then
    echo "🔑 Configuring Talos credentials..."
    mkdir -p "$HERMES_DATA/.talos"
    echo "$TALOS_CONFIG" > "$HERMES_DATA/.talos/config"
    chmod 600 "$HERMES_DATA/.talos/config"
fi

# 4. Profile Symlinking (Scalable)
if [ -d "$HERMES_DATA/profiles" ]; then
    echo "🔗 Linking profile configurations..."
    find "$HERMES_DATA/profiles" -mindepth 1 -maxdepth 1 -type d | while read -r profile_dir; do
        ln -sf "$HERMES_DATA/config.yaml" "$profile_dir/config.yaml"
    done
fi

# 5. Verify installation
export DOTNET_ROOT="$DOTNET_ROOT"
export PATH="$DOTNET_ROOT:$PATH"
export GIT_ASKPASS="$HERMES_DATA/bin/git-askpass"
export GIT_TERMINAL_PROMPT=0

echo "🧪 Verifying .NET installation..."
if ! "$DOTNET_ROOT/dotnet" --info >/dev/null 2>&1; then
    echo "⚠️ .NET verification failed. Checking for ICU issues..."
    if ! ldconfig -p 2>/dev/null | grep -qi libicu; then
        echo "🔧 ICU not found. Enabling globalization invariant mode for verification..."
        export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
        if "$DOTNET_ROOT/dotnet" --info >/dev/null 2>&1; then
            echo "✅ .NET verified successfully (Invariant Mode)."
        else
            echo "❌ .NET verification failed even in Invariant Mode."
            exit 1
        fi
    else
        echo "❌ .NET verification failed for unknown reasons."
        exit 1
    fi
else
    echo "✅ .NET verified successfully."
fi

# 6. Persist environment for the main container and interactive shells
echo "📝 Persisting environment to $HERMES_DATA/hermes.env and .bashrc..."
cat > "$HERMES_DATA/hermes.env" <<EOF
export DOTNET_ROOT="$DOTNET_ROOT"
export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
export PATH="$BIN_DIR:$DOTNET_ROOT:\$PATH"
export GIT_ASKPASS="$HERMES_DATA/bin/git-askpass"
export GIT_TERMINAL_PROMPT=0
export TALOSCONFIG="$HERMES_DATA/.talos/config"
EOF

# Also update .bashrc for interactive shells (since HOME=/opt/data)
cat > "$HERMES_DATA/.bashrc" <<EOF
# Hermes Environment
source "$HERMES_DATA/hermes.env"
EOF

# Ensure all newly installed binaries and configs are owned by Hermes (uid 10000)
chown -R 10000:10000 "$HERMES_DATA"

echo "✨ Setup Complete!"

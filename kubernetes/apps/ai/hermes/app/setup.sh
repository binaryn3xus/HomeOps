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

# 2. Master Config Setup
if [ -f "/tmp/config-source/config.yaml" ]; then
    echo "📝 Synchronizing master configuration..."
    cp /tmp/config-source/config.yaml "$HERMES_DATA/config.yaml"
fi

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
export PATH="$DOTNET_ROOT:\$PATH"
EOF

# Also update .bashrc for interactive shells (since HOME=/opt/data)
cat > "$HERMES_DATA/.bashrc" <<EOF
# Hermes Environment
source "$HERMES_DATA/hermes.env"
EOF

echo "✨ Setup Complete!"

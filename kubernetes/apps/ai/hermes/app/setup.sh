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
if [ ! -f "$DOTNET_ROOT/dotnet" ]; then
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

echo "✨ Setup Complete!"

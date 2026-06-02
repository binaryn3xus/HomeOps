#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
DOTNET_VERSION="10.0"
HERMES_DATA="/opt/data"
DOTNET_ROOT="$HERMES_DATA/dotnet"

echo "🌿 Hermes Operator Setup Starting..."

# 1. Ensure directories exist
mkdir -p "$DOTNET_ROOT"
mkdir -p "$HERMES_DATA/profiles"

# 2. Master Config Setup
echo "📝 Synchronizing master configuration..."
# The operator might mount its own config, but we ensure our persistent one is linked
if [ -f "/tmp/config-source/config.yaml" ]; then
    cp /tmp/config-source/config.yaml "$HERMES_DATA/config.yaml"
else
    echo "⚠️ Warning: /tmp/config-source/config.yaml not found. Checking /opt/data/config.yaml..."
fi

# 3. .NET SDK Installation (Persistent)
if [ ! -f "$DOTNET_ROOT/dotnet" ]; then
    echo "🚀 Installing .NET $DOTNET_VERSION SDK..."
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel "$DOTNET_VERSION" || \
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel STS
else
    echo "✅ .NET SDK already present at $DOTNET_ROOT"
fi

# 4. Profile Symlinking & Gateway Safety
echo "🔗 Linking profile configurations..."
if [ -d "$HERMES_DATA/profiles" ]; then
    find "$HERMES_DATA/profiles" -mindepth 1 -maxdepth 1 -type d | while read -r profile_dir; do
        profile_name=$(basename "$profile_dir")
        echo "  -> Processing @$profile_name"
        ln -sf "$HERMES_DATA/config.yaml" "$profile_dir/config.yaml"
        echo '{"gateway_state": "stopped"}' > "$profile_dir/gateway_state.json"
    done
fi

# 5. Global State Setup
echo '{"gateway_state": "running"}' > "$HERMES_DATA/gateway_state.json"

echo "✨ Setup Complete!"

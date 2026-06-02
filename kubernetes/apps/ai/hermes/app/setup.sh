#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
DOTNET_VERSION="10.0"
HERMES_DATA="/home/hermes/.hermes"
DOTNET_ROOT="$HERMES_DATA/dotnet"

echo "🌿 Hermes Operator Setup Starting..."

# 1. Ensure directories exist
mkdir -p "$DOTNET_ROOT"
mkdir -p "$HERMES_DATA/profiles"

# 2. .NET SDK Installation (Persistent)
if [ ! -f "$DOTNET_ROOT/dotnet" ]; then
    echo "🚀 Installing .NET $DOTNET_VERSION SDK..."
    # Try 10.0 first, fallback to current STS (9.0) if 10.0 is not yet available in the channel
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel "$DOTNET_VERSION" || \
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
        --install-dir "$DOTNET_ROOT" \
        --channel STS
else
    echo "✅ .NET SDK already present at $DOTNET_ROOT"
fi

# 3. Profile Symlinking & Gateway Safety
echo "🔗 Linking profile configurations..."
# Link every existing profile to the master config and ensure they don't start redundant gateways
if [ -d "$HERMES_DATA/profiles" ]; then
    find "$HERMES_DATA/profiles" -mindepth 1 -maxdepth 1 -type d | while read -r profile_dir; do
        profile_name=$(basename "$profile_dir")
        echo "  -> Processing @$profile_name"
        # The operator mounts the master config at /home/hermes/.hermes/config.yaml
        ln -sf "$HERMES_DATA/config.yaml" "$profile_dir/config.yaml"
        # Force named profiles to "stopped" state so they don't fight over the Discord token
        echo '{"gateway_state": "stopped"}' > "$profile_dir/gateway_state.json"
    done
fi

# 4. Global State Setup
# Ensure the root (default) gateway is marked as running so S6 starts it
echo '{"gateway_state": "running"}' > "$HERMES_DATA/gateway_state.json"

# Note: No 'chown' needed here as fsGroup: 10000 handles it at the K8s level.

echo "✨ Setup Complete!"

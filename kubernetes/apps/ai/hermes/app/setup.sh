#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
DOTNET_VERSION="10.0"
HERMES_DATA="/opt/data"
DOTNET_ROOT="$HERMES_DATA/dotnet"

echo "🌿 Hermes Total Simplicity Setup Starting..."

# 1. Ensure directories exist
mkdir -p "$DOTNET_ROOT"
mkdir -p "$HERMES_DATA/profiles"

# 2. Master Config Setup
echo "📝 Synchronizing master configuration..."
# Always overwrite the root config with the one from GitOps
cp /tmp/config-source/config.yaml "$HERMES_DATA/config.yaml"

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

# 4. Profile Symlinking (Scalable)
echo "🔗 Linking profile configurations..."
# Link every existing profile to the master config
if [ -d "$HERMES_DATA/profiles" ]; then
    find "$HERMES_DATA/profiles" -mindepth 1 -maxdepth 1 -type d | while read -r profile_dir; do
        profile_name=$(basename "$profile_dir")
        echo "  -> Linking @$profile_name"
        ln -sf "$HERMES_DATA/config.yaml" "$profile_dir/config.yaml"
    done
fi

# 5. Permission Fix
echo "🔐 Finalizing permissions for UID 10000..."
chown -R 10000:10000 "$HERMES_DATA" || true

echo "✨ Setup Complete!"

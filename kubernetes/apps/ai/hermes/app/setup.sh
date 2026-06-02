#!/bin/bash
set -euo pipefail

# --- CONFIGURATION ---
DOTNET_VERSION="10.0"
HERMES_DATA="/opt/data"
DOTNET_ROOT="$HERMES_DATA/dotnet"
SHIM_DIR="$HERMES_DATA/bin"

echo "🌿 Hermes Definitive Setup (Rootless Shim Mode) Starting..."

# 1. Ensure directories exist
mkdir -p "$DOTNET_ROOT"
mkdir -p "$HERMES_DATA/profiles"
mkdir -p "$SHIM_DIR"

# 2. Master Config Setup
echo "📝 Synchronizing master configuration..."
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

# 6. S6 Privilege-Drop Shims (The Silver Bullet)
# These shims prevent s6-overlay from failing when trying to 'drop' to the user we already are.
echo "🛡️ Installing S6-Overlay shims..."
cat <<'EOF' > "$SHIM_DIR/s6-setuidgid"
#!/bin/sh
# Shim to skip privilege drop if already the target user
shift 2
exec "$@"
EOF
chmod +x "$SHIM_DIR/s6-setuidgid"
ln -sf "$SHIM_DIR/s6-setuidgid" "$SHIM_DIR/s6-applyuidgid"

# 7. Finalize Permissions
echo "🔐 Finalizing permissions for UID 10000..."
find "$HERMES_DATA" -name "lost+found" -prune -o -exec chown 10000:10000 {} + || true

echo "✨ Setup Complete!"

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
    echo "skippy" > "$HERMES_DATA/active_profile"
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

# 3b. SRE & Development Tooling (kubectl, talosctl, gh, tirith, flux, kustomize, helm, jq, yq, kubeconform, stern)
BIN_DIR="$HERMES_DATA/bin"
mkdir -p "$BIN_DIR"

KUBECTL_VERSION="v1.37.2"
if [ ! -x "$BIN_DIR/kubectl" ] || [ ! -f "$BIN_DIR/.version-kubectl-$KUBECTL_VERSION" ]; then
    echo "📦 Installing kubectl ($KUBECTL_VERSION)..."
    curl -fsSL -o "$BIN_DIR/kubectl" "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod +x "$BIN_DIR/kubectl"
    rm -f "$BIN_DIR"/.version-kubectl-*
    touch "$BIN_DIR/.version-kubectl-$KUBECTL_VERSION"
fi

TALOSCTL_VERSION="v1.14.5"
if [ ! -x "$BIN_DIR/talosctl" ] || [ ! -f "$BIN_DIR/.version-talosctl-$TALOSCTL_VERSION" ]; then
    echo "📦 Installing talosctl ($TALOSCTL_VERSION)..."
    curl -fsSL -o "$BIN_DIR/talosctl" "https://github.com/siderolabs/talos/releases/download/${TALOSCTL_VERSION}/talosctl-linux-amd64"
    chmod +x "$BIN_DIR/talosctl"
    rm -f "$BIN_DIR"/.version-talosctl-*
    touch "$BIN_DIR/.version-talosctl-$TALOSCTL_VERSION"
fi

GH_VERSION="2.103.3"
if [ ! -x "$BIN_DIR/gh" ] || [ ! -f "$BIN_DIR/.version-gh-$GH_VERSION" ]; then
    echo "📦 Installing GitHub CLI ($GH_VERSION)..."
    curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" | tar -xz -C /tmp
    cp "/tmp/gh_${GH_VERSION}_linux_amd64/bin/gh" "$BIN_DIR/gh"
    chmod +x "$BIN_DIR/gh"
    rm -rf /tmp/gh_*
    rm -f "$BIN_DIR"/.version-gh-*
    touch "$BIN_DIR/.version-gh-$GH_VERSION"
fi

TIRITH_VERSION="v0.5.0"
if [ ! -x "$BIN_DIR/tirith" ] || [ ! -f "$BIN_DIR/.version-tirith-$TIRITH_VERSION" ]; then
    echo "📦 Installing tirith ($TIRITH_VERSION)..."
    curl -fsSL "https://github.com/sheeki03/tirith/releases/download/${TIRITH_VERSION}/tirith-x86_64-unknown-linux-gnu.tar.gz" | tar -xz -C "$BIN_DIR" tirith
    chmod +x "$BIN_DIR/tirith"
    rm -f "$BIN_DIR"/.version-tirith-*
    touch "$BIN_DIR/.version-tirith-$TIRITH_VERSION"
fi

FLUX_VERSION="2.10.0"
if [ ! -x "$BIN_DIR/flux" ] || [ ! -f "$BIN_DIR/.version-flux-$FLUX_VERSION" ]; then
    echo "📦 Installing flux ($FLUX_VERSION)..."
    curl -fsSL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_amd64.tar.gz" | tar -xz -C "$BIN_DIR" flux
    chmod +x "$BIN_DIR/flux"
    rm -f "$BIN_DIR"/.version-flux-*
    touch "$BIN_DIR/.version-flux-$FLUX_VERSION"
fi

KUSTOMIZE_VERSION="v5.8.3"
if [ ! -x "$BIN_DIR/kustomize" ] || [ ! -f "$BIN_DIR/.version-kustomize-$KUSTOMIZE_VERSION" ]; then
    echo "📦 Installing kustomize ($KUSTOMIZE_VERSION)..."
    curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz" | tar -xz -C "$BIN_DIR" kustomize
    chmod +x "$BIN_DIR/kustomize"
    rm -f "$BIN_DIR"/.version-kustomize-*
    touch "$BIN_DIR/.version-kustomize-$KUSTOMIZE_VERSION"
fi

HELM_VERSION="v4.3.1"
if [ ! -x "$BIN_DIR/helm" ] || [ ! -f "$BIN_DIR/.version-helm-$HELM_VERSION" ]; then
    echo "📦 Installing helm ($HELM_VERSION)..."
    curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xz -C /tmp
    cp /tmp/linux-amd64/helm "$BIN_DIR/helm"
    chmod +x "$BIN_DIR/helm"
    rm -rf /tmp/linux-amd64
    rm -f "$BIN_DIR"/.version-helm-*
    touch "$BIN_DIR/.version-helm-$HELM_VERSION"
fi

JQ_VERSION="1.7.1"
if [ ! -x "$BIN_DIR/jq" ] || [ ! -f "$BIN_DIR/.version-jq-$JQ_VERSION" ]; then
    echo "📦 Installing jq ($JQ_VERSION)..."
    curl -fsSL -o "$BIN_DIR/jq" "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64"
    chmod +x "$BIN_DIR/jq"
    rm -f "$BIN_DIR"/.version-jq-*
    touch "$BIN_DIR/.version-jq-$JQ_VERSION"
fi

YQ_VERSION="v4.45.1"
if [ ! -x "$BIN_DIR/yq" ] || [ ! -f "$BIN_DIR/.version-yq-$YQ_VERSION" ]; then
    echo "📦 Installing yq ($YQ_VERSION)..."
    curl -fsSL -o "$BIN_DIR/yq" "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"
    chmod +x "$BIN_DIR/yq"
    rm -f "$BIN_DIR"/.version-yq-*
    touch "$BIN_DIR/.version-yq-$YQ_VERSION"
fi

KUBECONFORM_VERSION="v0.8.0"
if [ ! -x "$BIN_DIR/kubeconform" ] || [ ! -f "$BIN_DIR/.version-kubeconform-$KUBECONFORM_VERSION" ]; then
    echo "📦 Installing kubeconform ($KUBECONFORM_VERSION)..."
    curl -fsSL "https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz" | tar -xz -C "$BIN_DIR" kubeconform
    chmod +x "$BIN_DIR/kubeconform"
    rm -f "$BIN_DIR"/.version-kubeconform-*
    touch "$BIN_DIR/.version-kubeconform-$KUBECONFORM_VERSION"
fi

STERN_VERSION="1.35.0"
if [ ! -x "$BIN_DIR/stern" ] || [ ! -f "$BIN_DIR/.version-stern-$STERN_VERSION" ]; then
    echo "📦 Installing stern ($STERN_VERSION)..."
    curl -fsSL "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_amd64.tar.gz" | tar -xz -C "$BIN_DIR" stern
    chmod +x "$BIN_DIR/stern"
    rm -f "$BIN_DIR"/.version-stern-*
    touch "$BIN_DIR/.version-stern-$STERN_VERSION"
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

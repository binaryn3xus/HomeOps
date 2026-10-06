#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="${1:-./.private/satisfactory/blueprints}"
SESSION_NAME="${2:-Project-MJOLNIR}"
NAMESPACE="default"
DEPLOYMENT="satisfactory"
CONTAINER="app"

echo "==> Satisfactory Blueprint Importer"

# 1. Check source directory
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Creating blueprint drop directory: $SOURCE_DIR"
    mkdir -p "$SOURCE_DIR"
    echo "Place your .sbp and .sbpcfg files into '$SOURCE_DIR' and run this command again."
    exit 0
fi

# Auto-unzip any .zip archives if present
shopt -s nullglob
zip_files=("$SOURCE_DIR"/*.zip)
if [ ${#zip_files[@]} -gt 0 ]; then
    for zip in "${zip_files[@]}"; do
        echo "Extracting archive: $(basename "$zip")..."
        unzip -q -o "$zip" -d "$SOURCE_DIR"
        rm -f "$zip"
    done
fi
shopt -u nullglob

# Count .sbp files
FILE_COUNT=$(find "$SOURCE_DIR" -type f -name "*.sbp" | wc -l)
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "No .sbp blueprint files found in '$SOURCE_DIR'."
    echo "Place your .sbp and .sbpcfg files (or a .zip of them) into '$SOURCE_DIR' and run this command again."
    exit 1
fi

echo "Found $FILE_COUNT blueprint(s) in '$SOURCE_DIR'."

# 2. Check if Satisfactory pod is running
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name="$DEPLOYMENT" -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | awk '{print $1}')

if [ -z "$POD_NAME" ]; then
    echo "Error: No running '$DEPLOYMENT' pod found in namespace '$NAMESPACE'."
    exit 1
fi

echo "Target pod: $POD_NAME"
TARGET_DIR="/config/saved/blueprints/$SESSION_NAME"

# 3. Create target directory inside pod if it does not exist
kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- mkdir -p "$TARGET_DIR"

# 4. Stream files into the pod safely preserving filenames with spaces
echo "Copying blueprints to $TARGET_DIR..."
tar -C "$SOURCE_DIR" --exclude='*:Zone.Identifier' -cf - . | kubectl exec -i -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- tar -C "$TARGET_DIR" -xf -

# 5. Fix permissions and maintain server symlinks
LOWER_SESSION=$(echo "$SESSION_NAME" | tr '[:upper:]' '[:lower:]')
kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- bash -c "
    chown -R 1000:1000 /config/saved/blueprints/
    chmod -R 775 /config/saved/blueprints/
    ln -sfn /config/saved/blueprints /config/saved/server/blueprints 2>/dev/null || true
    ln -sfn /config/saved/blueprints/$SESSION_NAME /config/saved/blueprints/Nexus 2>/dev/null || true
    ln -sfn /config/saved/blueprints/$SESSION_NAME /config/saved/blueprints/$LOWER_SESSION 2>/dev/null || true
"

echo "✔ Successfully imported $FILE_COUNT blueprint(s) into '$SESSION_NAME'!"
echo "Note: If the Blueprint tab is not visible in-game, ensure Tier 4 ('FICSIT Blueprints') is unlocked in the HUB."

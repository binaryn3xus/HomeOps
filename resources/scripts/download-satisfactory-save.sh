#!/usr/bin/env bash
set -euo pipefail

SAVE_NAME="${1:-}"
DEST_DIR="${2:-./.private/satisfactory/saves}"
NAMESPACE="default"
DEPLOYMENT="satisfactory"
CONTAINER="app"
SAVES_DIR="/config/saved/server"

echo "==> Satisfactory Save Downloader"

# 1. Check if Satisfactory pod is running
POD_NAME=$(kubectl get pods -n "$NAMESPACE" -l app.kubernetes.io/name="$DEPLOYMENT" -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}' | awk '{print $1}')

if [ -z "$POD_NAME" ]; then
    echo "Error: No running '$DEPLOYMENT' pod found in namespace '$NAMESPACE'." >&2
    exit 1
fi

echo "Connected to pod: $POD_NAME"

# Helper function to list available saves
list_saves() {
    local limit="${1:-}"
    echo "Available saves in '$SAVES_DIR':"
    local cmd="find \"$SAVES_DIR\" -maxdepth 1 -name \"*.sav\" -type f -printf \"%TY-%Tm-%Td %TH:%TM:%TS\t%s\t%f\n\" | sort -r"
    if [ -n "$limit" ]; then
        cmd="$cmd | head -n $limit"
    fi
    kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- bash -c "$cmd" | while IFS=$'\t' read -r mtime size name; do
        printf "  %-45s  %10s  %s\n" "$name" "$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "$size B")" "$mtime"
    done
}

# Handle 'list' option
if [ "$SAVE_NAME" = "list" ] || [ "$SAVE_NAME" = "--list" ]; then
    list_saves
    exit 0
fi

# 2. Determine target save file
TARGET_FILE=""

if [ -z "$SAVE_NAME" ] || [ "$SAVE_NAME" = "latest" ]; then
    LATEST_SAVE=$(kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- find "$SAVES_DIR" -maxdepth 1 -name "*.sav" -type f -printf "%T@\t%f\n" | sort -rn | head -n 1 | cut -f2)
    if [ -z "$LATEST_SAVE" ]; then
        echo "Error: No save files (.sav) found in '$SAVES_DIR' on pod $POD_NAME." >&2
        exit 1
    fi
    TARGET_FILE="$LATEST_SAVE"
    echo "==> No save name specified (or requested 'latest'). Selecting newest save: $TARGET_FILE"
else
    if kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- test -f "$SAVES_DIR/$SAVE_NAME" 2>/dev/null; then
        TARGET_FILE="$SAVE_NAME"
    elif kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- test -f "$SAVES_DIR/${SAVE_NAME}.sav" 2>/dev/null; then
        TARGET_FILE="${SAVE_NAME}.sav"
    else
        # Try pattern search (e.g. partial name or timestamp match)
        CLEAN_QUERY="${SAVE_NAME%.sav}"
        MATCHES=$(kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- find "$SAVES_DIR" -maxdepth 1 -iname "*${CLEAN_QUERY}*.sav" -type f -printf "%T@\t%f\n" | sort -rn)
        if [ -n "$MATCHES" ]; then
            TARGET_FILE=$(echo "$MATCHES" | head -n 1 | cut -f2)
            MATCH_COUNT=$(echo "$MATCHES" | wc -l)
            if [ "$MATCH_COUNT" -gt 1 ]; then
                echo "==> Found $MATCH_COUNT saves matching '$SAVE_NAME'. Selected newest: $TARGET_FILE"
            else
                echo "==> Matched save: $TARGET_FILE"
            fi
        else
            echo "Error: No save file matching '$SAVE_NAME' found in '$SAVES_DIR' on pod $POD_NAME." >&2
            echo "" >&2
            list_saves 10 >&2
            exit 1
        fi
    fi
fi

# 3. Ensure destination directory exists
mkdir -p "$DEST_DIR"

# 4. Stream save file from pod
echo "Downloading '$TARGET_FILE' to '$DEST_DIR/'..."
kubectl exec -n "$NAMESPACE" "$POD_NAME" -c "$CONTAINER" -- tar -C "$SAVES_DIR" -cf - "$TARGET_FILE" | tar -C "$DEST_DIR" -xf -

if [ ! -f "$DEST_DIR/$TARGET_FILE" ]; then
    echo "Error: Download failed; destination file '$DEST_DIR/$TARGET_FILE' not found." >&2
    exit 1
fi

DEST_SIZE=$(stat -c%s "$DEST_DIR/$TARGET_FILE" 2>/dev/null || wc -c < "$DEST_DIR/$TARGET_FILE")
HUMAN_SIZE=$(numfmt --to=iec-i --suffix=B "$DEST_SIZE" 2>/dev/null || echo "$DEST_SIZE bytes")

echo "✔ Successfully downloaded '$TARGET_FILE' ($HUMAN_SIZE) to '$DEST_DIR/'"

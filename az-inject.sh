#!/bin/bash
set -eo pipefail

if ! az account show &> /dev/null; then
    echo "Error: You are not logged into Azure. Please run 'az login'." >&2
    exit 1
fi

content=$(cat)

# Find all unique placeholders and sort by length, descending (longest first).
placeholders=$(echo "$content" | grep -o 'azkv://[a-zA-Z0-9_-]\+/[a-zA-Z0-9_-]\+' | sort -u | awk '{ print length, $0 }' | sort -rn | cut -d' ' -f2-)

echo "Placeholders (in order):" >&2
echo "$placeholders" >&2

if [ -z "$placeholders" ]; then
    echo "$content"
    exit 0
fi

# Process each placeholder line-by-line to avoid word splitting issues
while IFS= read -r placeholder; do
    [ -z "$placeholder" ] && continue

    vault_name=$(echo "$placeholder" | cut -d'/' -f3)
    secret_name=$(echo "$placeholder" | cut -d'/' -f4)

    echo "Injecting secret: ${secret_name} from vault: ${vault_name}" >&2
    secret_value=$(az keyvault secret show --vault-name "$vault_name" --name "$secret_name" --query 'value' -o tsv)

    # Replace only the exact placeholder string
    content="${content//"$placeholder"/"$secret_value"}"
done <<< "$placeholders"

echo "$content"

#!/bin/bash
set -eo pipefail

# Ensure the user is logged into Azure CLI
if ! az account show &> /dev/null; then
    echo "Error: You are not logged into Azure. Please run 'az login'." >&2
    exit 1
fi

content=$(cat)
placeholders=$(echo "$content" | grep -o 'azkv://[a-zA-Z0-9-]\+/[a-zA-Z0-9-]\+' || true)

if [ -z "$placeholders" ]; then
    echo "$content"
    exit 0
fi

for placeholder in $(echo "$placeholders" | sort -u); do
    vault_name=$(echo "$placeholder" | cut -d'/' -f3)
    secret_name=$(echo "$placeholder" | cut -d'/' -f4)

    echo "Injecting secret: ${secret_name} from vault: ${vault_name}" >&2
    secret_value=$(az keyvault secret show --vault-name "$vault_name" --name "$secret_name" --query 'value' -o tsv)

    # Use sed with a different delimiter to handle special characters
    content=$(echo "$content" | sed "s|${placeholder}|${secret_value}|g")
done

echo "$content"

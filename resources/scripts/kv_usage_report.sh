#!/usr/bin/env bash
set -euo pipefail
vault_name=${1:-K8sHomeOpsKeyVault}
PATTERN=".private/az-logs/.kv-secrets-${vault_name}.txt"
UNUSED=".private/az-logs/.kv-unused-${vault_name}.txt"
az keyvault secret list --vault-name "${vault_name}" --query '[].name' -o tsv | sort -u > "${PATTERN}"
total=$(wc -l < "${PATTERN}")
: > "${UNUSED}"
while IFS= read -r name; do
  if ! grep -R -q -F --exclude-dir=.git --exclude-dir=node_modules --exclude="${PATTERN}" "${name}" .; then
    echo "${name}" >> "${UNUSED}"
  fi
done < "${PATTERN}"
unused=$(wc -l < "${UNUSED}")
echo "Vault: ${vault_name}"
echo "Secrets: ${total}"
echo "Unused: ${unused}"
if [ "${unused}" -gt 0 ]; then
  echo "Unused list (first 50):"
  head -n 50 "${UNUSED}"
else
  echo "All secrets are referenced at least once."
fi
echo
echo "Sample references (first 100 lines):"
grep -R -n -F -f "${PATTERN}" . --exclude-dir=.git --exclude-dir=node_modules --exclude="${PATTERN}" | head -n 100 || true

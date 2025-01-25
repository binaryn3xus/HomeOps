# Scripts

## Clean Orphaned Secrets Cert Manager

Path to Script: `scripts/clean-orphan-cert-secrets.sh`

### Reason

Error: `unable to fetch certificate that owns the secret`

This script will find TLS secrets in a given namespace which have no matching certificate resource and delete them.

### Usage
`./clean-orphans.sh <namespace>`

Specifying no namespace will check the default. You will be prompted before anything is deleted.

---

## Stern

Project Link: [stern](https://github.com/stern/stern)

examples:
- `stern -n kube-system coredns`

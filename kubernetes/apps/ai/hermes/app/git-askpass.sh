#!/bin/sh
# Used by Git for HTTPS operations when a credential prompt would otherwise
# fail in Hermes' non-interactive container.
case "$1" in
  *Username*) printf '%s\n' "${GITHUB_USERNAME:-x-access-token}" ;;
  *Password*) printf '%s\n' "${GITHUB_TOKEN:-${GH_TOKEN:?A GitHub token is required for HTTPS authentication}}" ;;
esac

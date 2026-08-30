#!/bin/sh
# Used by Git for HTTPS operations when a credential prompt would otherwise
# fail in Hermes' non-interactive container.
case "$1" in
  *Username*) printf '%s\n' "x-access-token" ;;
  *Password*) printf '%s\n' "${GH_TOKEN:?GH_TOKEN is required for GitHub HTTPS authentication}" ;;
esac

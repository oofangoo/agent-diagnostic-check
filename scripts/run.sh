#!/usr/bin/env bash
# OpenClaw Health Check — skill runner
# Installs (if needed) and runs the openclaw-health-check CLI.
#
# Usage:
#   ./scripts/run.sh --session <SESSION_ID>
#   ./scripts/run.sh --offline
#   ./scripts/run.sh --session <SESSION_ID> --suite security

set -euo pipefail

# Check Node.js availability
if ! command -v node &>/dev/null; then
  echo "Error: Node.js >= 18 is required but not found." >&2
  exit 1
fi

# Check minimum Node version
NODE_MAJOR=$(node -e "console.log(process.versions.node.split('.')[0])")
if [ "$NODE_MAJOR" -lt 18 ]; then
  echo "Error: Node.js >= 18 required (found v$(node -v))." >&2
  exit 1
fi

# Run via npx — installs automatically if not present
exec npx openclaw-health-check "$@"

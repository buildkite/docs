#!/usr/bin/env bash
# Outputs the latest stable buildkite-agent release tag (e.g. v3.121.0)

set -euo pipefail

curl -sS -f "https://api.github.com/repos/buildkite/agent/releases/latest" \
  | grep '"tag_name"' \
  | sed 's/.*"tag_name": "\([^"]*\)".*/\1/'

#!/usr/bin/env bash
# Outputs the latest stable buildkite-agent release tag (for example, v4.0.0)

set -euo pipefail

curl -sS -f "https://api.github.com/repos/buildkite/agent/releases/latest" \
  | grep '"tag_name"' \
  | sed 's/.*"tag_name": "\([^"]*\)".*/\1/'

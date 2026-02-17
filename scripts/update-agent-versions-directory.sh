#!/usr/bin/env bash

set -euo pipefail

# This script generates documentation for Buildkite Agent 3.x versions.
# It fetches release data from GitHub and generates a Markdown file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Output file for generated docs
OUTPUT_FILE="${REPO_ROOT}/pages/agent/v3/self_hosted/versions_directory.md"

echo "Generating supported agent versions documentation..."
echo "Output file: ${OUTPUT_FILE}"
echo ""

# Run the Ruby generator script
ruby "${SCRIPT_DIR}/agent_versions_directory2md/agent_versions_directory2md.rb" > "${OUTPUT_FILE}"

echo ""
echo "Done! Generated documentation at ${OUTPUT_FILE}"

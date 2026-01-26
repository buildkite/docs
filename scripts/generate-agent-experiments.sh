#!/usr/bin/env bash

set -euo pipefail

# This script generates documentation for Buildkite agent experiments.
# It fetches experiment data from the agent repo and generates a Markdown file.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"

# Output file for generated docs
OUTPUT_FILE="${REPO_ROOT}/pages/agent/v3/self_hosted/configure/experiments.md"

echo "Generating agent experiments documentation..."
echo "Output file: ${OUTPUT_FILE}"
echo ""

# Run the Ruby generator script
ruby "${SCRIPT_DIR}/generate_agent_experiments/generate_agent_experiments.rb" > "${OUTPUT_FILE}"

echo ""
echo "Done! Generated documentation at ${OUTPUT_FILE}"

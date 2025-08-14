#!/usr/bin/env bash

set -euo pipefail

scripts_dir=$(dirname "${BASH_SOURCE[0]}")
base_dir=$(git rev-parse --show-toplevel)
file="${base_dir}/data/content/agent_attributes.yaml"

ruby "${scripts_dir}/parse-agent-attributes.rb" >"$file"

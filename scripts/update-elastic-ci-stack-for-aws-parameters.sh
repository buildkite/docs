#!/bin/bash
set -euo pipefail

template_url="${1:-https://s3.amazonaws.com/buildkite-aws-stack/latest/aws-stack.yml}"
output_path="pages/agent/v3/elastic_ci_aws/aws-stack.yml"

echo "Fetching template from ${template_url} to ${output_path}" >&2
curl --fail --silent --show-error --location "${template_url}" > "${output_path}"

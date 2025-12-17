#!/bin/bash
set -euo pipefail

page_path="pages/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/configuration_parameters.md"
output_path="pages/agent/v3/aws/elastic_ci_stack/ec2_linux_and_windows/configuration_parameters.md"

echo "Running ERB on template ${page_path}" >&2
erb "${page_path}" > "${output_path}"

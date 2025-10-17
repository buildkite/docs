#!/bin/bash
set -euo pipefail

page_path="pages/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/template_parameters.md"
output_path="pages/agent/v3/aws/elastic-ci-stack/ec2-linux-and-windows/template_parameters.md"

echo "Running ERB on template ${page_path}" >&2
erb "${page_path}" > "${output_path}"

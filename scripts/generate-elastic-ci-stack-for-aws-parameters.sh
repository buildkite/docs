#!/bin/bash
set -euo pipefail

page_path="pages/agent/v3/elastic_ci_aws/template_parameters.md.erb"
output_path="pages/agent/v3/elastic_ci_aws/template_parameters.md"

echo "Running ERB on template ${page_path}" >&2
erb "${page_path}" > "${output_path}"

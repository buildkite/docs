#!/usr/bin/env bash

set -euo pipefail

base_dir="$(git rev-parse --show-toplevel)"
output_file="${base_dir}/pages/agent/v3/self_hosted/supported_versions.md"

echo "Fetching all releases from github.com/buildkite/agent..."

# Fetch all releases from GitHub API, paginating through all pages
releases="[]"
page=1

while true; do
  response=$(curl -s "https://api.github.com/repos/buildkite/agent/releases?per_page=100&page=${page}")

  # Break if empty array
  count=$(echo "${response}" | jq 'length')
  if [[ "${count}" -eq 0 ]]; then
    break
  fi

  releases=$(echo "${releases}" "${response}" | jq -s '.[0] + .[1]')
  page=$((page + 1))
done

total=$(echo "${releases}" | jq 'length')
echo "Found ${total} releases"

# Generate the markdown file
cat > "${output_file}" << 'HEADER'
# Supported agent versions

The following list of Buildkite agent releases, listed in reverse chronological order, are versions which are supported by Buildkite. Each version links to its release notes on GitHub.

> 📘 Unsupported agent versions
> Earlier agent versions not listed on this page (that is, version 2 and earlier, as well as beta releases) are either deprecated or not supported. However, these versions are still available from the [Buildkite Agent releases](https://github.com/buildkite/agent/releases) page on GitHub.

HEADER

echo "${releases}" | jq -r '
  [.[] | select(.draft == false and (.tag_name | test("beta"; "i") | not)) |
    ((.tag_name | capture("^v(?<major>[0-9]+)\\.(?<minor>[0-9]+)") // {major: "0", minor: "0"}) |
      {major: (.major | tonumber), minor: (.minor | tonumber)}) as $ver |
    {tag_name, published_at, major: $ver.major, minor: $ver.minor,
     minor_group: (($ver.minor / 10 | floor) * 10)}
  ] |
  group_by(.major) | sort_by(-(.[0].major)) | [.[] | select(.[0].major >= 3)] | .[] |
  . as $major_releases |
  "\n## Version \(.[0].major) releases\n",
  ($major_releases | group_by(.minor_group) | sort_by(-(.[0].minor_group)) | .[] |
    "\n### v\(.[0].major).\(.[0].minor_group) to v\(.[0].major).\(.[0].minor_group + 9)\n",
    (sort_by(.published_at) | reverse | .[] |
      "- [`\(.tag_name)`](https://github.com/buildkite/agent/releases/tag/\(.tag_name)) — \(.published_at | split("T")[0])"
    )
  )
' >> "${output_file}"

# Ensure file ends with a newline
echo "" >> "${output_file}"

echo "Updated ${output_file}"

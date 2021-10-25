#!/bin/bash

set -euo pipefail

release_url=""
if [ -z "${AGENT_RELEASE_TAG:-}" ]
then
	release_url="https://api.github.com/repos/buildkite/agent/releases/latest"
else
	release_url="https://api.github.com/repos/buildkite/agent/releases/tags/${AGENT_RELEASE_TAG}"
fi

# Get OS name, e.g. darwin, linux
os="$(uname -s | tr '[:upper:]' '[:lower:]')"

# Get Architecture, e.g. arm64, amd64
case "$(uname -m)" in
	aarch64|arm64)
		arch="arm64"
		;;
	x86_64)
		arch="amd64"
		;;
esac

echo "Locating ${os}/${arch} binary for ${release_url}..."
asset_url="$(curl --fail --silent --show-error --location "$release_url" | jq -r ".assets | .[] | select(.name | startswith(\"buildkite-agent-${os}-${arch}\")) | .browser_download_url")"

echo "Downloading ${asset_url}..." >&2
# Fetch the agent tarball, pipe directly to tar to e(x)tract and decompress(z), unarchive in the tmp dir
curl --fail --show-error --location "${asset_url}" | tar -xzf - -C tmp

echo "Updating agent help with downloaded agent..." >&2
PATH="$PWD/tmp:$PATH" ./scripts/update-agent-help.sh

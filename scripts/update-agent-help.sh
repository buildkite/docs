#!/bin/bash
set -euo pipefail

commands=(
  "annotate"
  "annotation remove"
  "artifact download"
  "artifact shasum"
  "artifact upload"
  "bootstrap"
  "meta-data exists"
  "meta-data get"
  "meta-data keys"
  "meta-data set"
  "pipeline upload"
  "start"
  "step get"
  "step update"
)

base_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")/.." ; pwd -P )

for command in "${commands[@]}" ; do
  file="${base_dir}/pages/agent/v3/help/_${command//[- ]/_}.txt"
  if [[ ! -f "$file" ]] ; then
    echo "File $file doesn't exist"
    exit 1
  fi

  echo Updating docs for buildkite-agent "$command"
  buildkite-agent $command --help | ruby cli2md.rb > "$file"
done

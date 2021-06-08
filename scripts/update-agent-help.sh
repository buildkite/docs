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

# This is awful, but I can't be bothered with figuring out multi dimensional arrays in bash
# or passing individual arguments as well as STDIN to ruby
# More than one of these pages is included in the same doc page, so we need H3 instead of H3
commands_to_demote=(
  "artifact download"
  "artifact shasum"
  "artifact upload"
  "meta-data exists"
  "meta-data get"
  "meta-data keys"
  "meta-data set"
  "step get"
  "step update"
)

scripts_dir="$(dirname "${BASH_SOURCE[0]}")"
base_dir=$( cd "${scripts_dir}/.." ; pwd -P )

for command in "${commands[@]}" ; do
  file="${base_dir}/pages/agent/v3/help/_${command//[- ]/_}.md"
  if [[ ! -f "$file" ]] ; then
    echo "File $file doesn't exist"
    exit 1
  fi

  echo Updating docs for buildkite-agent "$command"
  buildkite-agent $command --help | ruby "${scripts_dir}/cli2md.rb" > "$file"
done

# The same awfulness, part II
for command in "${commands_to_demote[@]}" ; do
  file="${base_dir}/pages/agent/v3/help/_${command//[- ]/_}.md"
  echo "Demoting H2 to H3 in $command"
  sed -i '' -e 's/^##/###/' "$file"
done
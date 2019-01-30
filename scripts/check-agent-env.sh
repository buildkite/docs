#!/bin/bash
set -euo pipefail

get_agent_env_vars() {
  LANG=C grep -ohr -e 'BUILDKITE_[a-zA-Z0-9_\-]*[a-zA-Z0-9]*' \
    --include '*.go' \
    --exclude 'clicommand/*' \
    --exclude '*_test.go' . \
    | grep -v BUILDKITE_X_ \
    | grep -v -e '^BUILDKITE_$' \
    | grep -v -e '^BUILDKITE_AGENT_META_DATA_' \
    | sort | uniq
}

get_docs_env_vars() {
  LANG=C  grep -ohr -e 'BUILDKITE_[a-zA-Z0-9_\-]*[a-zA-Z0-9]' . \
    --include '*.erb' --exclude ".agent/" --exclude ".git" \
    | sort | uniq
}

cleanup() {
  rm agent_env_vars.txt
  rm docs_env_vars.txt
  rm -rf .agent/
}

trap cleanup EXIT

(
  [ -d .agent ] || git clone https://github.com/buildkite/agent.git .agent/
  cd .agent/
  echo "Generating agent env vars"
  get_agent_env_vars > ../agent_env_vars.txt
)

echo "Generating docs env vars"
get_docs_env_vars > docs_env_vars.txt

undocumented=()
echo "📖 🔍 Checking env in agent are documented"

while read -r env ; do
  if ! grep -q -e "${env}" docs_env_vars.txt ; then
   undocumented+=("$env")
  fi
done < agent_env_vars.txt

if [ ${#undocumented[@]} -eq 0 ] ; then
  echo "All Agent ENV are documented! 💃"
else
  for env in "${undocumented[@]}" ; do
    echo "🚨 $env isn't documented"
    (cd .agent; git --no-pager grep -n "$env")
    echo
  done
fi


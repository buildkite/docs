#!/bin/bash
set -euo pipefail

BASE_REF="${1:-origin/main}"

GENERATED_GRAPHQL_PATHS=(
  "data/graphql/schema.graphql"
  "data/nav_graphql.yml"
  "pages/apis/graphql/schemas"
)

GENERATED_CHANGES=$(git status --porcelain --untracked-files=all -- "${GENERATED_GRAPHQL_PATHS[@]}")

if [ -z "${GENERATED_CHANGES}" ]; then
  exit 0
fi

echo "Discarding changes to generated GraphQL reference files:"
echo "${GENERATED_CHANGES}"
touch "${DISCARDED_GENERATED_GRAPHQL_MARKER:-/tmp/docs-draft-discarded-generated-graphql}"

git restore --source="${BASE_REF}" --staged --worktree -- "${GENERATED_GRAPHQL_PATHS[@]}"
git clean -fd -- "${GENERATED_GRAPHQL_PATHS[@]}"

REMAINING_CHANGES=$(git status --porcelain --untracked-files=all -- "${GENERATED_GRAPHQL_PATHS[@]}")
if [ -n "${REMAINING_CHANGES}" ]; then
  echo "Error: Could not discard all generated GraphQL reference changes:" >&2
  echo "${REMAINING_CHANGES}" >&2
  exit 1
fi

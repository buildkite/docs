#!/usr/bin/env sh

if ! command -v vale >/dev/null 2>&1; then
  echo >&2 "vale not found"
  echo >&2 "for installation instructions, go to https://vale.sh/"
  exit 1
fi

DOCS_ROOT=$(dirname "$(dirname "$(realpath "$0")")")

# TODO: Reinstate linting of pages/agent/v3/help/_bootstrap.md
# The file contains an unresolvable spelling error (because the genuine source of the file lives outside this repo).
# When the spelling error is fixed, remove the `--glob` option to reinstate linting.
# See https://github.com/buildkite/docs/pull/1585/#discussion_r893429064 and https://github.com/buildkite/agent/pull/1672.
vale --config "$DOCS_ROOT"/vale/.vale.ini --glob='!*/pages/agent/v3/help/_bootstrap.md' "$DOCS_ROOT"/pages &&
  vale --config "$DOCS_ROOT/vale/.vale.snippets.ini" "$DOCS_ROOT"/pages/**/_*

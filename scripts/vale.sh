#!/usr/bin/env sh

if ! command -v vale >/dev/null 2>&1; then
  echo >&2 "vale not found"
  echo >&2 "for installation instructions, go to https://vale.sh/"
  exit 1
fi

DOCS_ROOT=$(dirname "$(dirname "$(realpath "$0")")")

vale --config "$DOCS_ROOT"/vale/.vale.ini "$DOCS_ROOT"/pages &&
  vale --config "$DOCS_ROOT/vale/.vale.snippets.ini" "$DOCS_ROOT"/pages/**/_*

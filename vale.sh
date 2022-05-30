#!/usr/bin/env sh

if ! command -v vale >/dev/null 2>&1; then
  echo >&2 "vale not found"
  echo >&2 "for installation instructions, go to https://vale.sh/"
  exit 1
fi

vale --config .vale.ini pages &&
  vale --config .vale.snippets.ini pages/**/_*

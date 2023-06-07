#!/bin/bash

# Find pull request number for a given branch.
#
# Why not `$BUILDKITE_PULL_REQUEST`? That env variable is only set
# for builds triggered via Github and it's possible previews are
# manually triggered via the API or Buildkite Dashboard.
#
function get_branch_pull_request_number() {
  gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/buildkite/docs/pulls \
    -X GET -f head="buildkite:$1" | jq ".[0].number | select (.!=null)"
}

function find_github_comment() {
  gh api \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/buildkite/docs/issues/$1/comments \
    | jq --arg msg "$2" '.[] | select(.body==$msg)'
}

function post_github_comment() {
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    /repos/buildkite/docs/issues/$1/comments \
    -f body="$2"
}

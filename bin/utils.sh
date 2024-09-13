#!/bin/bash

# Find pull request number for a given branch.
#
# Why not `$BUILDKITE_PULL_REQUEST`? That env variable is only set
# for builds triggered via Github and it's possible previews are
# manually triggered via the API or Buildkite Dashboard.

# ensure GH_REPO env var is present
if [ -z "$GH_REPO" ]; then
  echo "GH_REPO env var is required"
  exit 1
fi

function get_branch_pull_request_number() {
  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/${GH_REPO}/pulls\?head=buildkite\:$1 \
    | jq ".[0].number | select (.!=null)"
}

function find_github_comment() {
  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/${GH_REPO}/issues/$1/comments \
    | jq --arg msg "$2" '.[] | select(.body==$msg)'
}

function post_github_comment() {
  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --data "{\"body\":\"$2\"}" \
    https://api.github.com/repos/${GH_REPO}/issues/$1/comments
}

function create_pull_request() {
  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --data "{\"title\":\"$1\", \"body\":\"$2\", \"head\":\"$BRANCH\", \"base\":\"main\"}" \
    "https://api.github.com/repos/${GH_REPO}/pulls"
}

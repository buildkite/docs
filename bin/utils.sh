#!/bin/bash

if [ -z "$GH_REPO" ]; then
  echo "GH_REPO env var is required"
  exit 1
fi

API_BASE_PATH="https://api.github.com/repos/${GH_REPO}"

# Find pull request number for a given branch.
#
# Why not `$BUILDKITE_PULL_REQUEST`? That env variable is only set
# for builds triggered via Github and it's possible previews are
# manually triggered via the API or Buildkite Dashboard.
function get_branch_pull_request_number() {
  local branch=$1

  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    ${API_BASE_PATH}/pulls\?head=buildkite\:${branch} \
    | jq ".[0].number | select (.!=null)"
}

function find_github_comment() {
  local pr_number="$1"
  local msg="$2"

  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    ${API_BASE_PATH}/issues/${pr_number}/comments \
    | jq --arg msg "$msg" '.[] | select(.body==$msg)'
}

function post_github_comment() {
  local pr_number=$1
  local msg=$2

  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --data "{\"body\":\"${msg}\"}" \
    ${API_BASE_PATH}/issues/${pr_number}/comments
}

function create_pull_request() {
  local title="$1"
  local body="$2"
  local branch="$3"

  local request_body=$(
    jq --null-input \
       --compact-output \
       --arg title "$title" \
       --arg body "$body" \
       --arg head "$branch" \
       --arg base "main" \
       '{title: $title, body: $body, head: $head, base: $base}'
  )

  curl -L \
    -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $GH_TOKEN" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    --json "$request_body" \
    "${API_BASE_PATH}/pulls"
}

function netlify_preview_id() {
    local branch=$1
    local salt=$2

    echo -n "${salt}${branch}" | sha1sum | awk '{print $1}'
}

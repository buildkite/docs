#!/bin/bash
set -euo pipefail

# changelog.sh — Orchestrates the AI-powered changelog drafting process.
#
# This script:
#   1. Installs dependencies (git, gh CLI, Claude Code)
#   2. Removes the "needs-changelog" label from the upstream PR (one-shot trigger)
#   3. Fetches PR context (title, body, diff, comments, reviews)
#   4. Clones the changelog repo and sets up a working branch
#   5. Builds a prompt and runs Claude Code to write a changelog entry
#   6. Commits and pushes any changes
#   7. Opens (or updates) a PR on the changelog repo
#   8. Comments on the upstream PR with the result
#
# Required environment variables:
#   UPSTREAM_REPO                — GitHub repo slug (e.g. "buildkite/agent")
#   UPSTREAM_PR_NUMBER           — PR number in the upstream repo
#   GITHUB_TOKEN                 — GitHub token for API access
#   BUILDKITE_AGENT_ACCESS_TOKEN — Buildkite job token (used for Model Provider API)
#
# Optional environment variables:
#   CLAUDE_MODEL                 — Claude model to use (default: "sonnet")
#   CLAUDE_MAX_TURNS             — Max agentic turns (default: 20)
#   DIFF_MAX_LINES               — Max lines of diff to include (default: 2000)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates"

# Configurable defaults
CLAUDE_MODEL="${CLAUDE_MODEL:-sonnet}"
CLAUDE_MAX_TURNS="${CLAUDE_MAX_TURNS:-20}"
DIFF_MAX_LINES="${DIFF_MAX_LINES:-2000}"

# --- Validate inputs ---

if [ -z "${UPSTREAM_REPO:-}" ] || [ -z "${UPSTREAM_PR_NUMBER:-}" ]; then
  echo "Error: UPSTREAM_REPO and UPSTREAM_PR_NUMBER must be set"
  exit 1
fi

echo "UPSTREAM_REPO: '${UPSTREAM_REPO}'"
echo "UPSTREAM_PR_NUMBER: '${UPSTREAM_PR_NUMBER}'"
echo "CLAUDE_MODEL: '${CLAUDE_MODEL}'"
echo "CLAUDE_MAX_TURNS: '${CLAUDE_MAX_TURNS}'"

# --- Set up API credentials ---
# The Model Provider API authenticates using the job token.
export ANTHROPIC_API_KEY="${BUILDKITE_AGENT_ACCESS_TOKEN}"
export GH_TOKEN="${GITHUB_TOKEN}"

# --- Install minimal dependencies for label check ---

echo "--- :hammer: Install dependencies"
apt-get update -qq && apt-get install -y -qq git curl jq > /dev/null 2>&1

# --- Check for "needs-changelog" label (unless WRITE_CHANGELOG is already set) ---
# When triggered automatically from an upstream pipeline, WRITE_CHANGELOG may not be set.
# In that case, check the PR's labels to decide whether to proceed.

if [ "${WRITE_CHANGELOG:-}" != "true" ]; then
  echo "--- :label: Checking for 'needs-changelog' label on ${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}"
  LABELS=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${UPSTREAM_REPO}/pulls/${UPSTREAM_PR_NUMBER}" \
    | jq -r '.labels[].name // empty' 2>/dev/null || true)
  echo "PR labels: ${LABELS:-<none>}"

  if ! echo "${LABELS}" | grep -q "^needs-changelog$"; then
    echo "No 'needs-changelog' label found, skipping changelog draft"
    exit 0
  fi
  echo "'needs-changelog' label found, proceeding"
fi

# Install gh CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update -qq && apt-get install -y -qq gh > /dev/null 2>&1

# Install Claude Code
npm install -g @anthropic-ai/claude-code@2.1.74 > /dev/null 2>&1

# Create non-root user (Claude Code refuses --dangerously-skip-permissions as root)
useradd -m -s /bin/bash claude-user

# --- Remove the "needs-changelog" label (one-shot trigger) ---

echo "--- :label: Remove needs-changelog label"
gh pr edit "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --remove-label "needs-changelog" \
  || echo "Warning: Could not remove label (may already be removed)"

# --- Fetch PR context ---

echo "--- :github: Fetch PR context"
PR_JSON=$(gh pr view "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --json title,body,url,comments,reviews)

PR_TITLE=$(echo "${PR_JSON}" | jq -r '.title')

# Strip Linear issue IDs (e.g. "A-970", "PKG-1234") from the title to prevent
# the GitHub/Linear integration from reopening issues on the changelog PR.
PR_TITLE_CLEAN=$(echo "${PR_TITLE}" | sed -E 's/\[?[A-Z]{1,5}-[0-9]+\]?[[:space:]:/-]*//' | sed 's/^[[:space:]]*//')
PR_BODY=$(echo "${PR_JSON}" | jq -r '.body // "No description provided."')
PR_URL=$(echo "${PR_JSON}" | jq -r '.url')
PR_COMMENTS=$(echo "${PR_JSON}" | jq -r '
  [.comments[]? | "\(.author.login) wrote:\n\(.body)"] | join("\n\n---\n\n") // "No comments."')
PR_REVIEWS=$(echo "${PR_JSON}" | jq -r '
  [.reviews[]? | "\(.author.login) (\(.state)):\n\(.body // "No body")"] | join("\n\n---\n\n") // "No reviews."')

# Cap the diff size to avoid overwhelming the prompt
PR_DIFF=$(gh pr diff "${UPSTREAM_PR_NUMBER}" --repo "${UPSTREAM_REPO}" | head -n "${DIFF_MAX_LINES}")

echo "PR: ${PR_TITLE}"
echo "URL: ${PR_URL}"

# --- Cache templates before switching directories ---

echo "--- :file_folder: Cache templates"
SYSTEM_PROMPT_FILE="/tmp/changelog-system.md"
cp "${SCRIPT_DIR}/../prompts/changelog-system.md" "${SYSTEM_PROMPT_FILE}"
COMMENT_NO_CHANGES=$(cat "${TEMPLATES_DIR}/changelog-no-changes.md")
COMMENT_CHANGELOG_CREATED_TEMPLATE=$(cat "${TEMPLATES_DIR}/comment-changelog-created.md")
CHANGELOG_PR_BODY_TEMPLATE=$(cat "${TEMPLATES_DIR}/changelog-pr-body.md")

# --- Clone changelog repo ---

CHANGELOG_DIR="/tmp/changelog"

echo "--- :git: Clone changelog repo"
git config --global --add safe.directory "${CHANGELOG_DIR}"
git clone "https://x-access-token:${GH_TOKEN}@github.com/buildkite/changelog.git" "${CHANGELOG_DIR}"

cd "${CHANGELOG_DIR}"

REPO_SLUG=$(echo "${UPSTREAM_REPO}" | sed 's|.*/||')
BRANCH_NAME="changelog/${REPO_SLUG}/pr-${UPSTREAM_PR_NUMBER}"

git config user.name "buildkite-docs-bot"
git config user.email "docs-bot@buildkite.com"
git checkout -B "${BRANCH_NAME}" origin/main

# --- Build prompt ---

echo "--- :writing_hand: Build prompt"
PROMPT_FILE="/tmp/changelog-prompt.md"
TODAY=$(date +%Y-%m-%d)
CURRENT_YEAR=$(date +%Y)

PR_TITLE_SAFE=$(printf '%s' "${PR_TITLE}" | sed 's/[|&\\]/\\&/g')

cat > "${PROMPT_FILE}" <<EOF
You are working in the Buildkite changelog repository.

Today's date is ${TODAY}. Write changelog files to \`changelogs/${CURRENT_YEAR}/\`.

An engineer has requested a changelog entry for the following upstream pull request:

**Repository:** ${UPSTREAM_REPO}
**PR:** #${UPSTREAM_PR_NUMBER} — ${PR_TITLE}
**URL:** ${PR_URL}

## Your task

Follow the instructions in your system prompt to:
1. Triage this PR — determine if a changelog entry is needed
2. If yes, write a changelog entry in this repository
3. If no, explain why and stop without making changes

## PR description

${PR_BODY}

## PR diff

\`\`\`diff
${PR_DIFF}
\`\`\`

## PR comments

${PR_COMMENTS}

## PR reviews

${PR_REVIEWS}
EOF

# --- Run Claude Code as non-root user ---

echo "--- :claude: Run Claude Code"
chown -R claude-user:claude-user "${CHANGELOG_DIR}" /tmp/changelog-*.md
su claude-user -c "
  export ANTHROPIC_API_KEY='${ANTHROPIC_API_KEY}'
  export ANTHROPIC_BASE_URL='${ANTHROPIC_BASE_URL}'
  export DISABLE_AUTOUPDATER=1
  export DISABLE_TELEMETRY=1
  cd '${CHANGELOG_DIR}'
  claude -p \
    --model '${CLAUDE_MODEL}' \
    --max-turns '${CLAUDE_MAX_TURNS}' \
    --verbose \
    --dangerously-skip-permissions \
    --output-format stream-json \
    --append-system-prompt-file '${SYSTEM_PROMPT_FILE}' \
    < '${PROMPT_FILE}'
" | while IFS= read -r line; do
    # Extract readable progress from stream-json output
    type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
    case "$type" in
      assistant)
        echo "$line" | jq -r '
          .message.content[]? |
          if .type == "tool_use" then "🔧 Tool: \(.name) — \(.input | tostring | .[0:200])"
          elif .type == "text" then "💬 \(.text | .[0:500])"
          else empty end
        ' 2>/dev/null
        ;;
      result)
        echo "$line" | jq -r '"✅ Result: \(.subtype // "done") — cost: $\(.cost_usd // "?")"' 2>/dev/null
        ;;
    esac
  done

# --- Check for changes ---

echo "--- :git: Check for changes"
if [ -z "$(git status --porcelain)" ]; then
  echo "No changelog entry was created."

  gh pr comment "${UPSTREAM_PR_NUMBER}" \
    --repo "${UPSTREAM_REPO}" \
    --body "${COMMENT_NO_CHANGES}" \
    || true

  exit 0
fi

# --- Commit and push ---

echo "--- :git: Commit and push changes"
git add -A
git commit -m "Changelog entry for ${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}

Auto-generated changelog entry for:
${PR_URL}"

git push --force origin "${BRANCH_NAME}"

# --- Open or update PR ---

echo "--- :github: Open or update PR"
EXISTING_PR=$(gh pr list \
  --repo buildkite/changelog \
  --head "${BRANCH_NAME}" \
  --json number \
  --jq '.[0].number // empty')

if [ -n "${EXISTING_PR}" ]; then
  echo "Updated existing PR #${EXISTING_PR}"
  CHANGELOG_PR_URL="https://github.com/buildkite/changelog/pull/${EXISTING_PR}"
else
  PR_BODY_CONTENT=$(echo "${CHANGELOG_PR_BODY_TEMPLATE}" | sed \
    -e "s|\${PR_URL}|${PR_URL}|g" \
    -e "s|\${UPSTREAM_REPO}|${UPSTREAM_REPO}|g")

  CHANGELOG_PR_URL=$(gh pr create \
    --repo buildkite/changelog \
    --base main \
    --head "${BRANCH_NAME}" \
    --title "[Changelog] ${PR_TITLE_CLEAN}" \
    --body "${PR_BODY_CONTENT}")
  echo "Created new PR: ${CHANGELOG_PR_URL}"
fi

# --- Comment on upstream PR ---

echo "--- :mega: Comment on upstream PR"
COMMENT_BODY=$(echo "${COMMENT_CHANGELOG_CREATED_TEMPLATE}" | sed \
  -e "s|\${CHANGELOG_PR_URL}|${CHANGELOG_PR_URL}|g")

gh pr comment "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --body "${COMMENT_BODY}" \
  || true

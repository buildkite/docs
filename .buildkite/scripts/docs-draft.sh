#!/bin/bash
set -euo pipefail

# docs-draft.sh — Orchestrates the AI-powered documentation drafting process.
#
# This script:
#   1. Installs dependencies (git, gh CLI, Claude Code)
#   2. Removes the "needs-docs" label from the upstream PR (one-shot trigger)
#   3. Fetches PR context (title, body, diff, comments, reviews)
#   4. Builds a prompt and runs Claude Code to analyze/write docs
#   5. Commits and pushes any changes
#   6. Opens (or updates) a draft PR on docs-private
#   7. Comments on the upstream PR with the result
#
# Required environment variables:
#   UPSTREAM_REPO                — GitHub repo slug (e.g. "buildkite/agent")
#   UPSTREAM_PR_NUMBER           — PR number in the upstream repo
#   GITHUB_TOKEN                 — GitHub token for API access
#   BUILDKITE_AGENT_ACCESS_TOKEN — Buildkite job token (used for Model Provider API)
#
# Optional environment variables:
#   CLAUDE_MODEL                 — Claude model to use (default: "sonnet")
#   CLAUDE_MAX_TURNS             — Max agentic turns (default: 50)
#   DIFF_MAX_LINES               — Max lines of diff to include (default: 2000)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="${SCRIPT_DIR}/../templates"

# Configurable defaults
CLAUDE_MODEL="${CLAUDE_MODEL:-sonnet}"
CLAUDE_MAX_TURNS="${CLAUDE_MAX_TURNS:-50}"
DIFF_MAX_LINES="${DIFF_MAX_LINES:-2000}"

# --- Validate required env vars ---

echo "--- :mag: Validating environment variables"

if [ -z "${UPSTREAM_REPO:-}" ] || [ -z "${UPSTREAM_PR_NUMBER:-}" ]; then
  echo "Error: UPSTREAM_REPO and UPSTREAM_PR_NUMBER must be set."
  echo "These are typically injected by the upstream trigger step or the input step."
  exit 1
fi

if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "Error: GITHUB_TOKEN is not set. Check the AWS SSM plugin configuration."
  exit 1
fi

if [ -z "${BUILDKITE_AGENT_ACCESS_TOKEN:-}" ]; then
  echo "Error: BUILDKITE_AGENT_ACCESS_TOKEN is not set."
  exit 1
fi

echo "UPSTREAM_REPO: '${UPSTREAM_REPO}'"
echo "UPSTREAM_PR_NUMBER: '${UPSTREAM_PR_NUMBER}'"
echo "CLAUDE_MODEL: '${CLAUDE_MODEL}'"
echo "CLAUDE_MAX_TURNS: '${CLAUDE_MAX_TURNS}'"

# --- Set up API credentials ---
# The Model Provider API authenticates using the job token.
# We set this here rather than in the step YAML to ensure we get
# the correct job token (not a stale one from a previous job).
export ANTHROPIC_API_KEY="${BUILDKITE_AGENT_ACCESS_TOKEN}"
export GH_TOKEN="${GITHUB_TOKEN}"

# --- Install dependencies ---

echo "--- :hammer: Install dependencies"
apt-get update -qq && apt-get install -y -qq git curl jq > /dev/null 2>&1

# Install gh CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update -qq && apt-get install -y -qq gh > /dev/null 2>&1

# Install Claude Code
npm install -g @anthropic-ai/claude-code > /dev/null 2>&1

# Create non-root user (Claude Code refuses --dangerously-skip-permissions as root)
useradd -m -s /bin/bash claude-user
chown -R claude-user:claude-user /workdir

# --- Remove the "needs-docs" label (one-shot trigger) ---

echo "--- :label: Remove needs-docs label"
gh pr edit "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --remove-label "needs-docs" \
  || echo "Warning: Could not remove label (may already be removed)"

# --- Fetch PR context ---

echo "--- :github: Fetch PR context"
PR_JSON=$(gh pr view "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --json title,body,url,comments,reviews)

PR_TITLE=$(echo "${PR_JSON}" | jq -r '.title')
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

# --- Cache templates before branch switch ---
# The checkout dir currently has our pipeline branch files. Once we switch to
# origin/main these will disappear, so read everything into variables and /tmp now.

echo "--- :file_folder: Cache templates"
PROMPT_TEMPLATE=$(cat "${TEMPLATES_DIR}/docs-draft-prompt.md")
SYSTEM_PROMPT_FILE="/tmp/docs-draft-system.md"
cp "${SCRIPT_DIR}/../prompts/docs-draft-system.md" "${SYSTEM_PROMPT_FILE}"
COMMENT_NO_CHANGES=$(cat "${TEMPLATES_DIR}/comment-no-changes.md")
COMMENT_DOCS_CREATED_TEMPLATE=$(cat "${TEMPLATES_DIR}/comment-docs-created.md")
DRAFT_PR_BODY_TEMPLATE=$(cat "${TEMPLATES_DIR}/draft-pr-body.md")

# --- Set up git branch ---

REPO_SLUG=$(echo "${UPSTREAM_REPO}" | sed 's|.*/||')
BRANCH_NAME="docs-draft/${REPO_SLUG}/pr-${UPSTREAM_PR_NUMBER}"

echo "--- :git: Set up branch"
# Mark checkout as safe (Docker runs as different user than checkout owner)
git config --global --add safe.directory /workdir
git config --global --add safe.directory /workdir/vendor/emojis

git config user.name "buildkite-docs-bot"
git config user.email "docs-bot@buildkite.com"
git remote set-url origin "https://x-access-token:${GH_TOKEN}@github.com/buildkite/docs-private.git"
git fetch origin main
git checkout -B "${BRANCH_NAME}" origin/main

# --- Build prompt from template ---

echo "--- :writing_hand: Build prompt"
PROMPT_FILE="/tmp/docs-draft-prompt.md"

# Substitute simple variables into the cached template.
# PR_TITLE is sanitized to avoid breaking sed (it could contain | or &).
PR_TITLE_SAFE=$(printf '%s' "${PR_TITLE}" | sed 's/[|&\\]/\\&/g')

echo "${PROMPT_TEMPLATE}" | sed \
  -e "s|\${UPSTREAM_REPO}|${UPSTREAM_REPO}|g" \
  -e "s|\${UPSTREAM_PR_NUMBER}|${UPSTREAM_PR_NUMBER}|g" \
  -e "s|\${PR_TITLE}|${PR_TITLE_SAFE}|g" \
  -e "s|\${PR_URL}|${PR_URL}|g" \
  > "${PROMPT_FILE}"

# Append the dynamic content via heredoc (safe for arbitrary content)
cat >> "${PROMPT_FILE}" <<SECTIONS

## PR description

${PR_BODY}

## PR comments

${PR_COMMENTS}

## PR review comments

${PR_REVIEWS}

## Code diff

\`\`\`diff
${PR_DIFF}
\`\`\`
SECTIONS

# --- Run Claude Code as non-root user ---
# Claude Code refuses --dangerously-skip-permissions when running as root.
# Give claude-user ownership of the workdir and tmp files, then run as that user.

echo "--- :claude: Run Claude Code"
chown -R claude-user:claude-user /workdir /tmp/docs-draft-*.md
su claude-user -c "
  export ANTHROPIC_API_KEY='${ANTHROPIC_API_KEY}'
  export ANTHROPIC_BASE_URL='${ANTHROPIC_BASE_URL}'
  export DISABLE_AUTOUPDATER=1
  export DISABLE_TELEMETRY=1
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
if git diff --quiet && git diff --cached --quiet; then
  echo "No documentation changes were made."

  gh pr comment "${UPSTREAM_PR_NUMBER}" \
    --repo "${UPSTREAM_REPO}" \
    --body "${COMMENT_NO_CHANGES}" \
    || true

  exit 0
fi

# --- Commit and push ---

echo "--- :git: Commit and push changes"
git add -A
git commit -m "Draft docs for ${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}

Auto-generated documentation draft for:
${PR_URL}"

git push --force origin "${BRANCH_NAME}"

# --- Open or update PR ---

echo "--- :github: Open or update PR"
EXISTING_PR=$(gh pr list \
  --repo buildkite/docs-private \
  --head "${BRANCH_NAME}" \
  --json number \
  --jq '.[0].number // empty')

if [ -n "${EXISTING_PR}" ]; then
  echo "Updated existing PR #${EXISTING_PR}"
  DOCS_PR_URL="https://github.com/buildkite/docs-private/pull/${EXISTING_PR}"
else
  # Build the PR body from template
  PR_BODY_CONTENT=$(echo "${DRAFT_PR_BODY_TEMPLATE}" | sed \
    -e "s|\${PR_URL}|${PR_URL}|g" \
    -e "s|\${UPSTREAM_REPO}|${UPSTREAM_REPO}|g")

  DOCS_PR_URL=$(gh pr create \
    --repo buildkite/docs-private \
    --base main \
    --head "${BRANCH_NAME}" \
    --title "[Docs Draft] ${PR_TITLE}" \
    --body "${PR_BODY_CONTENT}")
  echo "Created new PR: ${DOCS_PR_URL}"
fi

# --- Comment on upstream PR ---

echo "--- :mega: Comment on upstream PR"
COMMENT_BODY=$(echo "${COMMENT_DOCS_CREATED_TEMPLATE}" | sed \
  -e "s|\${DOCS_PR_URL}|${DOCS_PR_URL}|g")

gh pr comment "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --body "${COMMENT_BODY}" \
  || true

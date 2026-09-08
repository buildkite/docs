#!/bin/bash
set -euo pipefail

# docs-draft.sh — Orchestrates the AI-powered documentation drafting process.
#
# This script:
#   1. Installs dependencies (git, gh CLI, Claude Code)
#   2. Fetches PR context (title, body, diff, comments, reviews)
#   3. Checks for feature flags in the diff and annotates the build
#   4. Builds a prompt and runs Claude Code to analyze/write docs
#   5. Commits and pushes any changes
#   6. Opens (or updates) a draft PR on docs-private
#   7. Annotates the build with the result; comments on the upstream PR only if a PR was created
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

# --- Annotate trigger ---
echo "Proceeding with docs draft for ${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}"
buildkite-agent annotate --style "info" --context "docs-trigger" \
  ":memo: Docs draft triggered for **${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}**" \
  || true

# Install gh CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt-get update -qq && apt-get install -y -qq gh > /dev/null 2>&1

# Install Claude Code
npm install -g @anthropic-ai/claude-code@2.1.221 > /dev/null 2>&1

# Create non-root user (Claude Code refuses --dangerously-skip-permissions as root)
useradd -m -s /bin/bash claude-user
chown -R claude-user:claude-user /workdir

# --- Fetch PR context ---

echo "--- :github: Fetch PR context"
PR_JSON=$(gh pr view "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --json title,body,url,author,comments,reviews)

PR_TITLE=$(echo "${PR_JSON}" | jq -r '.title')

# Strip Linear issue IDs (e.g. "A-970", "PKG-1234") from the title to prevent
# the GitHub/Linear integration from reopening issues on the docs PR.
PR_TITLE_CLEAN=$(echo "${PR_TITLE}" | sed -E 's/\[?[A-Z]{1,5}-[0-9]+\]?[[:space:]:/-]*//' | sed 's/^[[:space:]]*//')
PR_BODY=$(echo "${PR_JSON}" | jq -r '.body // "No description provided."')
PR_URL=$(echo "${PR_JSON}" | jq -r '.url')
PR_AUTHOR=$(echo "${PR_JSON}" | jq -r '.author.login // empty')
PR_AUTHOR_IS_BOT=$(echo "${PR_JSON}" | jq -r '.author.is_bot // false')

# Copy the engineer's public documentation selection into the generated docs
# PR so reviewers can see it without returning to the upstream PR.
PUBLIC_DOCUMENTATION=$(printf '%s\n' "${PR_BODY}" | awk '
  /^###[[:space:]]+Public documentation[[:space:]]*$/ { found = 3; next }
  /^##[[:space:]]+Public documentation[[:space:]]*$/ { found = 2; next }
  found == 3 && /^##[#]?[[:space:]]+/ { exit }
  found == 2 && /^##[[:space:]]+/ { exit }
  found { print }
')
if [ -z "${PUBLIC_DOCUMENTATION//[[:space:]]/}" ]; then
  PUBLIC_DOCUMENTATION="The upstream PR did not provide public documentation instructions. Confirm with the upstream author whether the documentation is safe to publish."
fi
PR_COMMENTS=$(echo "${PR_JSON}" | jq -r '
  [.comments[]? | "\(.author.login) wrote:\n\(.body)"] | join("\n\n---\n\n") // "No comments."')
PR_REVIEWS=$(echo "${PR_JSON}" | jq -r '
  [.reviews[]? | "\(.author.login) (\(.state)):\n\(.body // "No body")"] | join("\n\n---\n\n") // "No reviews."')

# Fetch the complete diff for feature-flag detection, then cap only the copy
# included in the model prompt. Detecting against the capped prompt could miss a
# feature file that appears after DIFF_MAX_LINES.
PR_DIFF_FILE="/tmp/docs-draft-upstream-pr.diff"
gh pr diff "${UPSTREAM_PR_NUMBER}" --repo "${UPSTREAM_REPO}" > "${PR_DIFF_FILE}"
PR_DIFF=$(head -n "${DIFF_MAX_LINES}" "${PR_DIFF_FILE}")

echo "PR: ${PR_TITLE}"
echo "URL: ${PR_URL}"

# --- Check for feature flags in the diff ---

echo "--- :triangular_flag_on_post: Checking for feature flags"
# Check canonical flag files and added lines only. V2 flags use CamelCase
# Feature::Base subclasses and may call active? with or without parentheses.
if { grep -E '^\+\+\+ b/app/models/feature/[^/]+\.rb$' "${PR_DIFF_FILE}" \
       | grep -Ev '/(base|base_store|caching_store|database_store|redis_store|status)\.rb$' > /dev/null; } \
  || grep -E '^\+\+\+ b/lib/buildkite/feature_flags/[^/]+\.rb$' "${PR_DIFF_FILE}" > /dev/null \
  || { grep -E '^\+' "${PR_DIFF_FILE}" | grep -Ev '^\+\+\+' \
       | grep -E '(class[[:space:]]+Feature::[A-Z][[:alnum:]_]*[[:space:]]*<[[:space:]]*Feature::Base|Feature::[A-Z][[:alnum:]_]*|Feature\.new([^[:alnum:]_]|$)|\.(active\?\(|active_for_[a-z_]+\?|activate_for_[a-z_]+|deactivate_for_[a-z_]+)|Billing::Plan::Feature)' > /dev/null; }; then
  echo "Feature flag indicators detected in diff"
  FEATURE_FLAG_DETECTED="true"
  buildkite-agent annotate --style "warning" --context "feature-flag" \
    ":triangular_flag_on_post: **Feature flag detected** — this PR may introduce a feature behind a flag. Review whether docs should note limited availability or be held until GA." \
    || true
else
  echo "No feature flag indicators found"
  FEATURE_FLAG_DETECTED="false"
fi

# --- Cache templates before branch switch ---
# The checkout dir currently has our pipeline branch files. Once we switch to
# origin/main these will disappear, so read everything into variables and /tmp now.

echo "--- :file_folder: Cache templates"
PROMPT_TEMPLATE=$(cat "${TEMPLATES_DIR}/docs-draft-prompt.md")
SYSTEM_PROMPT_FILE="/tmp/docs-draft-system.md"
cp "${SCRIPT_DIR}/../prompts/docs-draft-system.md" "${SYSTEM_PROMPT_FILE}"
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

# Safety net: if Claude committed changes despite instructions not to,
# reset them back to working-tree changes so the status check detects them.
git reset origin/main --quiet 2>/dev/null || true

echo "--- :git: Check for changes"
if [[ -z "$(git status --porcelain)" ]]; then
  echo "No documentation changes were made."
  buildkite-agent annotate --style "info" --context "docs-result" \
    ":white_check_mark: Claude reviewed **${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}** and determined no documentation changes were needed." \
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

# Build the PR body from the latest upstream public documentation selection.
FEATURE_FLAG_STATUS=$([ "${FEATURE_FLAG_DETECTED}" = "true" ] && echo "Yes — review whether docs should note limited availability" || echo "No")
PR_BODY_CONTENT=$(echo "${DRAFT_PR_BODY_TEMPLATE}" | sed \
  -e "s|\${PR_URL}|${PR_URL}|g" \
  -e "s|\${UPSTREAM_REPO}|${UPSTREAM_REPO}|g" \
  -e "s|\${FEATURE_FLAG_STATUS}|${FEATURE_FLAG_STATUS}|g" \
  -e "s|\${BUILD_URL}|${BUILDKITE_BUILD_URL}|g")
PUBLIC_DOCUMENTATION_FILE="/tmp/docs-draft-public-documentation.md"
printf '%s\n' "${PUBLIC_DOCUMENTATION}" > "${PUBLIC_DOCUMENTATION_FILE}"
PR_BODY_CONTENT=$(printf '%s\n' "${PR_BODY_CONTENT}" | awk -v public_documentation_file="${PUBLIC_DOCUMENTATION_FILE}" '
  $0 == "${PUBLIC_DOCUMENTATION}" {
    while ((getline line < public_documentation_file) > 0) print line
    close(public_documentation_file)
    next
  }
  { print }
')

if [ -n "${EXISTING_PR}" ]; then
  echo "Updated existing PR #${EXISTING_PR}"
  DOCS_PR_URL="https://github.com/buildkite/docs-private/pull/${EXISTING_PR}"
  gh pr edit "${EXISTING_PR}" \
    --repo buildkite/docs-private \
    --body "${PR_BODY_CONTENT}"
else
  DOCS_PR_URL=$(gh pr create \
    --repo buildkite/docs-private \
    --base main \
    --head "${BRANCH_NAME}" \
    --title "[Docs Draft] ${PR_TITLE_CLEAN}" \
    --body "${PR_BODY_CONTENT}" \
    --draft)
  echo "Created new PR: ${DOCS_PR_URL}"
fi

# Ask the upstream author to verify technical accuracy and publication readiness.
# A missing author, a bot-authored PR, or a failed review request must not prevent
# the docs draft from being created.
if [ -n "${PR_AUTHOR}" ] && [ "${PR_AUTHOR_IS_BOT}" != "true" ]; then
  echo "--- :eyes: Request review from upstream author @${PR_AUTHOR}"
  gh pr edit "${DOCS_PR_URL}" \
    --repo buildkite/docs-private \
    --add-reviewer "${PR_AUTHOR}" \
    || echo "Could not request review from @${PR_AUTHOR}; continuing"
else
  echo "Skipping upstream author review request"
fi

# --- Annotate build and comment on upstream PR ---

buildkite-agent annotate --style "success" --context "docs-result" \
  ":memo: Docs draft PR created for **${UPSTREAM_REPO}#${UPSTREAM_PR_NUMBER}**: ${DOCS_PR_URL}" \
  || true

echo "--- :mega: Comment on upstream PR"
COMMENT_BODY=$(echo "${COMMENT_DOCS_CREATED_TEMPLATE}" | sed \
  -e "s|\${DOCS_PR_URL}|${DOCS_PR_URL}|g")

gh pr comment "${UPSTREAM_PR_NUMBER}" \
  --repo "${UPSTREAM_REPO}" \
  --body "${COMMENT_BODY}" \
  || true

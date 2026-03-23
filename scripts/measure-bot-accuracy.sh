#!/bin/bash
#
# measure-bot-accuracy.sh
#
# Measures the accuracy of bk-docsbot AI style review suggestions on PRs.
#
# Classification logic (in priority order):
#   1. COMMITTED  — A Co-authored-by commit exists that matches the suggestion text
#   2. REJECTED   — The comment has a 👎 reaction
#   3. ACCEPTED   — The comment has a 👍 reaction
#   4. APPLIED    — The suggestion text appears in the final merged file (manual apply)
#   5. NOT APPLIED — The suggestion text does NOT appear in the final merged file
#   6. UNKNOWN    — PR not merged or file deleted; can't determine
#
# Usage:
#   ./scripts/measure-bot-accuracy.sh [--limit N] [--pr NUMBER] [--verbose] [--all]
#
# Requires: gh (GitHub CLI), authenticated with access to the repo.

set -euo pipefail

REPO="buildkite/docs-private"
BOT_USER="bk-docsbot"
CO_AUTHOR_PATTERN="Co-authored-by.*[Dd]ocs.[Bb]ot"
LIMIT=25
SPECIFIC_PR=""
VERBOSE=false
FEEDBACK=false
REVIEW_ALL=false

# Deduplication: track which PRs have already been reviewed
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REVIEWED_FILE="$SCRIPT_DIR/.bot-reviewed-prs"

# Counters
total=0
committed=0
accepted_reaction=0
rejected_reaction=0
applied=0
not_applied=0
unknown=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --limit) LIMIT="$2"; shift 2 ;;
    --pr) SPECIFIC_PR="$2"; shift 2 ;;
    --verbose) VERBOSE=true; shift ;;
    --feedback) FEEDBACK=true; VERBOSE=true; shift ;;
    --all) REVIEW_ALL=true; shift ;;
    --help|-h)
      echo "Usage: $0 [--limit N] [--pr NUMBER] [--verbose] [--feedback] [--all]"
      echo ""
      echo "  --limit N      Max number of recent PRs to scan (default: 25)"
      echo "  --pr NUMBER    Analyze a single PR"
      echo "  --verbose      Show per-suggestion details"
      echo "  --feedback     Export detailed feedback for prompt improvement"
      echo "  --all          Re-analyze all PRs, ignoring .bot-reviewed-prs"
      exit 0
      ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

log() {
  if [[ "$VERBOSE" == true ]]; then
    echo "$*"
  fi
}

# Read lines into an array, compatible with bash 3 (no mapfile)
read_lines() {
  local arr_name="$1"
  local line
  eval "$arr_name=()"
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    eval "$arr_name+=(\"\$line\")"
  done
}

# Load already-reviewed PR numbers (unless --all or --pr is used)
reviewed_prs=""
if [[ "$REVIEW_ALL" == false ]] && [[ -z "$SPECIFIC_PR" ]] && [[ -f "$REVIEWED_FILE" ]]; then
  reviewed_prs=$(cat "$REVIEWED_FILE")
  reviewed_count=$(echo "$reviewed_prs" | grep -c '[0-9]' || true)
  echo "Loaded $reviewed_count previously reviewed PRs from .bot-reviewed-prs"
  echo "  (use --all to re-analyze them)"
fi

is_reviewed() {
  local pr_num="$1"
  [[ -n "$reviewed_prs" ]] && echo "$reviewed_prs" | grep -qx "$pr_num"
}

mark_reviewed() {
  local pr_num="$1"
  # Don't update the file when targeting a single PR
  [[ -n "$SPECIFIC_PR" ]] && return
  # Append if not already present
  if ! grep -qx "$pr_num" "$REVIEWED_FILE" 2>/dev/null; then
    echo "$pr_num" >> "$REVIEWED_FILE"
  fi
}

# Collect PR numbers to analyze
if [[ -n "$SPECIFIC_PR" ]]; then
  pr_numbers=("$SPECIFIC_PR")
else
  echo "Scanning last $LIMIT closed PRs for bot suggestions..."
  read_lines pr_numbers < <(
    gh api "/repos/$REPO/pulls?state=closed&per_page=$LIMIT" \
      --jq '.[].number'
  )
fi

echo ""

skipped=0
for pr in "${pr_numbers[@]+"${pr_numbers[@]}"}"; do
  # Skip PRs that have already been reviewed
  if is_reviewed "$pr"; then
    skipped=$((skipped + 1))
    continue
  fi
  # Get bot comments that contain suggestion blocks
  read_lines comment_ids < <(
    gh api "/repos/$REPO/pulls/$pr/comments" \
      --jq ".[] | select(.user.login == \"$BOT_USER\") | select(.body | test(\"\`\`\`suggestion\")) | .id" 2>/dev/null || true
  )

  [[ ${#comment_ids[@]} -eq 0 ]] && continue

  # Get PR metadata
  pr_data=$(gh api "/repos/$REPO/pulls/$pr" --jq '{merged, head_sha: .head.sha, state}' 2>/dev/null)
  merged=$(echo "$pr_data" | jq -r '.merged')
  head_sha=$(echo "$pr_data" | jq -r '.head_sha')

  # Build a lookup of added lines from co-authored commits (for COMMITTED classification)
  co_authored_lines=""
  co_authored_shas=()
  if [[ "$merged" == "true" ]]; then
    read_lines co_authored_shas < <(
      gh api "/repos/$REPO/pulls/$pr/commits" \
        --jq ".[] | select(.commit.message | test(\"$CO_AUTHOR_PATTERN\")) | .sha" 2>/dev/null || true
    )
    for sha in "${co_authored_shas[@]+"${co_authored_shas[@]}"}"; do
      [[ -z "$sha" ]] && continue
      patch_lines=$(gh api "/repos/$REPO/commits/$sha" \
        --jq '[.files[] | .filename as $f | .patch // "" | split("\n")[] | select(startswith("+")) | select(startswith("+++") | not) | "\($f):\(.[1:])"] | join("\n")' 2>/dev/null || true)
      co_authored_lines="${co_authored_lines}"$'\n'"${patch_lines}"
    done
  fi

  echo "PR #$pr (${#comment_ids[@]} suggestions, merged=$merged)"

  for comment_id in "${comment_ids[@]+"${comment_ids[@]}"}"; do
    [[ -z "$comment_id" ]] && continue
    total=$((total + 1))

    # Fetch comment details
    comment_data=$(gh api "/repos/$REPO/pulls/comments/$comment_id" \
      --jq '{body, path, reactions_plus: .reactions["+1"], reactions_minus: .reactions["-1"]}' 2>/dev/null)

    body=$(echo "$comment_data" | jq -r '.body')
    path=$(echo "$comment_data" | jq -r '.path')
    plus1=$(echo "$comment_data" | jq -r '.reactions_plus')
    minus1=$(echo "$comment_data" | jq -r '.reactions_minus')

    # Extract suggestion text from ```suggestion block
    suggestion=$(echo "$body" | sed -n '/^```suggestion$/,/^```$/p' | sed '1d;$d')

    if [[ -z "$suggestion" ]]; then
      log "  ⚪ #$comment_id ($path) — no suggestion block found"
      unknown=$((unknown + 1))
      continue
    fi

    classification=""

    # Detect whether this suggestion was committed via the button
    was_committed=false
    if [[ -n "$co_authored_lines" ]]; then
      first_line=$(echo "$suggestion" | grep -v '^$' | head -1)
      if [[ -n "$first_line" ]] && echo "$co_authored_lines" | grep -qF -- "$first_line"; then
        was_committed=true
      fi
    fi

    # 1. Explicit reactions always win — they are deliberate human signals
    if [[ "$minus1" -gt 0 ]]; then
      classification="REJECTED (👎)"
      rejected_reaction=$((rejected_reaction + 1))
    elif [[ "$plus1" -gt 0 ]]; then
      if [[ "$was_committed" == true ]]; then
        classification="COMMITTED"
        committed=$((committed + 1))
      else
        classification="ACCEPTED (👍)"
        accepted_reaction=$((accepted_reaction + 1))
      fi
    fi

    # 2. No reaction — check if it was committed via the button
    if [[ -z "$classification" ]] && [[ "$was_committed" == true ]]; then
      classification="COMMITTED"
      committed=$((committed + 1))
    fi

    # 3. Check if suggestion text appears in the final merged file
    if [[ -z "$classification" ]] && [[ "$merged" == "true" ]]; then
      file_content=$(gh api "/repos/$REPO/contents/$path?ref=$head_sha" \
        --jq '.content' 2>/dev/null | base64 -d 2>/dev/null || true)

      if [[ -n "$file_content" ]]; then
        first_line=$(echo "$suggestion" | grep -v '^$' | head -1)
        if [[ -n "$first_line" ]] && echo "$file_content" | grep -qF -- "$first_line"; then
          classification="APPLIED"
          applied=$((applied + 1))
        else
          classification="NOT APPLIED"
          not_applied=$((not_applied + 1))
        fi
      else
        classification="UNKNOWN"
        unknown=$((unknown + 1))
      fi
    fi

    # 4. Fallback
    if [[ -z "$classification" ]]; then
      classification="UNKNOWN"
      unknown=$((unknown + 1))
    fi

    suggestion_preview=$(echo "$suggestion" | head -1 | cut -c1-70)
    log "$(printf '  %-18s #%s (%s) — %s' "$classification" "$comment_id" "$path" "$suggestion_preview")"

    # --feedback: output detailed context for prompt improvement
    if [[ "$FEEDBACK" == true ]]; then
      # Extract the bot's reasoning (text before the suggestion block)
      reasoning=$(echo "$body" | sed '/^```suggestion$/,$d' | sed '/^$/d')

      # Fetch reply comments to this bot comment
      replies=$(gh api "/repos/$REPO/pulls/$pr/comments" \
        --jq "[.[] | select(.in_reply_to_id == $comment_id) | {user: .user.login, body: .body}]" 2>/dev/null || echo "[]")
      reply_count=$(echo "$replies" | jq 'length')

      echo ""
      echo "--- FEEDBACK ITEM ---"
      echo "PR: #$pr"
      echo "File: $path"
      echo "Classification: $classification"
      echo "Comment URL: https://github.com/$REPO/pull/$pr#discussion_r$comment_id"
      echo ""
      echo "Bot reasoning:"
      echo "$reasoning" | sed 's/^/  /'
      echo ""
      echo "Bot suggestion:"
      echo "$suggestion" | sed 's/^/  /'

      if [[ "$reply_count" -gt 0 ]]; then
        echo ""
        echo "Human replies ($reply_count):"
        echo "$replies" | jq -r '.[] | "  @\(.user): \(.body)"'
      fi

      if [[ "$minus1" -gt 0 ]] || echo "$classification" | grep -q "NOT APPLIED"; then
        echo ""
        echo "⚠️  This suggestion was REJECTED — useful for identifying prompt weaknesses."
      fi
      echo "--- END FEEDBACK ITEM ---"
      echo ""
    fi
  done

  # Record this PR as reviewed
  mark_reviewed "$pr"
done

# Sort the reviewed file for cleanliness
if [[ -f "$REVIEWED_FILE" ]]; then
  sort -un "$REVIEWED_FILE" -o "$REVIEWED_FILE"
fi

echo ""
echo "========================================"
echo "  Bot Suggestion Accuracy Report"
echo "========================================"
echo ""
if [[ $skipped -gt 0 ]]; then
  echo "PRs skipped (already reviewed): $skipped"
  echo ""
fi
echo "Total suggestions analyzed:  $total"
echo ""
echo "  ✅ COMMITTED (via button):   $committed"
echo "  👍 ACCEPTED (reaction):      $accepted_reaction"
echo "  📝 APPLIED (in final file):  $applied"
echo "  👎 REJECTED (reaction):      $rejected_reaction"
echo "  ❌ NOT APPLIED:              $not_applied"
echo "  ❓ UNKNOWN:                  $unknown"
echo ""

if [[ $total -gt 0 ]]; then
  accepted_total=$((committed + accepted_reaction + applied))
  rejected_total=$((rejected_reaction + not_applied))
  determined=$((accepted_total + rejected_total))

  echo "  Accepted (all signals):  $accepted_total / $total ($(( accepted_total * 100 / total ))%)"
  echo "  Rejected (all signals):  $rejected_total / $total ($(( rejected_total * 100 / total ))%)"
  echo "  Unknown:                 $unknown / $total ($(( unknown * 100 / total ))%)"

  if [[ $determined -gt 0 ]]; then
    echo ""
    echo "  Accuracy (accepted / determined):  $accepted_total / $determined ($(( accepted_total * 100 / determined ))%)"
  fi
fi

echo ""

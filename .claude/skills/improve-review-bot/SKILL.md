---
name: improve-review-bot
description: Analyze feedback on bk-docsbot suggestions to identify rejection patterns and draft prompt improvements that increase accuracy. Run this periodically to close the feedback loop.
---

# Improve the documentation review bot

You are analyzing feedback on the `bk-docsbot` — an AI-powered documentation style reviewer — to improve its accuracy.

## Locate project files

This skill lives inside the docs repo. Derive all paths from the skill directory:

```
REPO_ROOT="${CLAUDE_SKILL_DIR}/../../.."
```

Key files relative to `${REPO_ROOT}`:

- **Feedback script**: `scripts/measure-bot-accuracy.sh`
- **Review agent**: `tools/pr-review-agent/main.go`
- **Style guide**: `AGENTS.md`
- **Prompt location**: `buildPrompt()` function in `main.go` (search for `func buildPrompt`)

---

## Context

The `bk-docsbot` is a Go program (`tools/pr-review-agent/main.go`) that uses Claude to review documentation PRs against the style guide in `AGENTS.md`. When it finds violations, it posts GitHub suggestion comments on the PR.

The bot's prompt has two parts:
1. **Style guide**: Loaded from `AGENTS.md` at the repo root
2. **Review instructions**: Hardcoded in the `buildPrompt()` function in `main.go` — this includes the "Critical Rules" that control behavior

## Step 1: Gather feedback

Run the measurement script with the `--feedback` flag to get detailed data:

```bash
cd "${REPO_ROOT}"
bash scripts/measure-bot-accuracy.sh --feedback 2>&1 | tee /tmp/bot-feedback.txt
```

This outputs every bot suggestion along with:
- The bot's reasoning for the suggestion
- The suggested code change
- The classification (COMMITTED, ACCEPTED, REJECTED, NOT APPLIED, and so on)
- Any human reply comments from the docs team
- Reaction data (👍/👎)

## Step 2: Analyze rejection patterns

Focus on items classified as `REJECTED` or `NOT APPLIED`. Look for patterns:

1. **Rule misapplication**: The bot cited a rule that doesn't apply to the context (for example, applying YAML rules to HTML, or prose rules to code)
2. **False positives**: The bot flagged something that wasn't actually a violation
3. **Context blindness**: The bot didn't understand the surrounding context (for example, ERB files, partial templates, intentional terminology)
4. **Overreach**: The bot suggested changes beyond what the style guide requires
5. **Domain errors**: The bot got Buildkite-specific terminology wrong

Group rejections by category. For each category, determine:
- How many rejections fall into this category?
- Is there a common trigger?
- Can this be fixed by adding a rule to the "Critical Rules" section, or does it need a style guide clarification?

## Step 3: Analyze accepted suggestions

Also review highly-accepted patterns (COMMITTED suggestions) to understand what the bot does well. This helps avoid accidentally weakening good behavior when fixing bad behavior.

## Step 4: Draft improvements

Based on the analysis, draft specific changes. There are two places changes can go:

### Changes to `buildPrompt()` in `main.go`

The "Critical Rules" section controls the bot's behavior. Add rules like:
- "Do not flag X in Y context"
- "When reviewing ERB files (.md.erb), be aware that..."
- "The term 'agent token' is correct when referring to..."

These are behavioral guardrails. Keep them concise and specific.

### Changes to `AGENTS.md`

If the style guide itself is ambiguous or missing a rule that caused confusion, propose a clarification there instead.

## Step 5: Draft a PR

Create a branch and commit the changes:

```bash
cd "${REPO_ROOT}"
git checkout main && git pull
git checkout -b improve-review-bot-prompt
# ... make edits ...
git add -A && git commit -m "Improve review bot prompt based on feedback analysis"
git push -u origin improve-review-bot-prompt
```

Then provide a PR description that includes:
- The current accuracy rate
- A summary of the rejection patterns found
- What changes were made and why
- Expected impact on accuracy

## Guidelines

- **Be conservative**: Only add rules you're confident about based on multiple data points
- **Be specific**: "Do not flag missing `</tr>` tags in HTML tables" is better than "Be more careful with HTML"
- **Don't weaken good behavior**: If the bot is 100% accepted on product naming suggestions, don't add caveats that might reduce that
- **Preserve the prompt's tone**: The existing Critical Rules section is terse and imperative — match that style
- **Show your work**: Include the data that supports each change in the PR description

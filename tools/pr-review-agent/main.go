package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"
)

const (
	model          = "claude-sonnet-4-5"
	maxTokens      = 4096
	anthropicVer   = "2023-06-01"
	defaultRepo    = "buildkite/docs-private"
	styleGuideName = "AGENTS.md"
)

// API mode - determined by which env vars are set
type APIMode int

const (
	ModeBuildkite APIMode = iota // Use Buildkite model provider
	ModeAnthropic                // Use Anthropic API directly
)

// Tool definitions for Claude
var tools = []Tool{
	{
		Name:        "get_line_number",
		Description: "Find the line number of specific text in a file. Returns the line number (1-indexed) where the text is found.",
		InputSchema: map[string]any{
			"type": "object",
			"properties": map[string]any{
				"file": map[string]any{
					"type":        "string",
					"description": "Path to the file relative to repo root",
				},
				"search_text": map[string]any{
					"type":        "string",
					"description": "Exact text to search for (can be partial line)",
				},
			},
			"required": []string{"file", "search_text"},
		},
	},
	{
		Name:        "submit_suggestion",
		Description: "Submit a suggested change as a GitHub PR review comment with a suggestion block. The reviewer can then click 'Commit suggestion' to apply it.",
		InputSchema: map[string]any{
			"type": "object",
			"properties": map[string]any{
				"file": map[string]any{
					"type":        "string",
					"description": "Path to the file relative to repo root",
				},
				"line": map[string]any{
					"type":        "integer",
					"description": "Line number in the file (1-indexed)",
				},
				"original": map[string]any{
					"type":        "string",
					"description": "The original line text (for verification)",
				},
				"replacement": map[string]any{
					"type":        "string",
					"description": "The suggested replacement text",
				},
				"reason": map[string]any{
					"type":        "string",
					"description": "Brief explanation of why this change is needed",
				},
			},
			"required": []string{"file", "line", "original", "replacement", "reason"},
		},
	},
	{
		Name:        "finish_review",
		Description: "Call this when you have finished reviewing the PR and submitted all suggestions. Provide a summary of findings.",
		InputSchema: map[string]any{
			"type": "object",
			"properties": map[string]any{
				"verdict": map[string]any{
					"type":        "string",
					"enum":        []string{"PASS", "NEEDS CHANGES"},
					"description": "Overall verdict for the PR",
				},
				"summary": map[string]any{
					"type":        "string",
					"description": "Brief summary of findings (1-2 sentences)",
				},
				"suggestion_count": map[string]any{
					"type":        "integer",
					"description": "Number of suggestions submitted",
				},
			},
			"required": []string{"verdict", "summary", "suggestion_count"},
		},
	},
}

// API types
type Tool struct {
	Name        string         `json:"name"`
	Description string         `json:"description"`
	InputSchema map[string]any `json:"input_schema"`
}

type Message struct {
	Role    string    `json:"role"`
	Content []Content `json:"content"`
}

type Content struct {
	Type      string `json:"type"`
	Text      string `json:"text,omitempty"`
	ID        string `json:"id,omitempty"`
	Name      string `json:"name,omitempty"`
	Input     any    `json:"input,omitempty"`
	ToolUseID string `json:"tool_use_id,omitempty"`
	Content   string `json:"content,omitempty"` // Used for tool_result
}

type Request struct {
	Model     string    `json:"model"`
	MaxTokens int       `json:"max_tokens"`
	Tools     []Tool    `json:"tools,omitempty"`
	Messages  []Message `json:"messages"`
}

type Response struct {
	ID           string    `json:"id"`
	Type         string    `json:"type"`
	Role         string    `json:"role"`
	Content      []Content `json:"content"`
	Model        string    `json:"model"`
	StopReason   string    `json:"stop_reason"`
	StopSequence string    `json:"stop_sequence"`
	Usage        Usage     `json:"usage"`
	Error        *APIError `json:"error,omitempty"`
}

type Usage struct {
	InputTokens  int `json:"input_tokens"`
	OutputTokens int `json:"output_tokens"`
}

type APIError struct {
	Type    string `json:"type"`
	Message string `json:"message"`
}

// Review context
type ReviewContext struct {
	PRNumber    string
	CommitSHA   string
	Repo        string
	RepoRoot    string
	APIEndpoint string
	APIToken    string
	APIMode     APIMode
	PRDiff      string
	StyleGuide  string
	Suggestions []Suggestion
	DryRun      bool // Don't post to GitHub, just print
}

type Suggestion struct {
	File        string
	Line        int
	Original    string
	Replacement string
	Reason      string
}

func printUsage() {
	fmt.Fprintf(os.Stderr, `PR Review Agent - Automated style guide review for Buildkite docs

Usage:
  pr-review-agent [PR_NUMBER] [OPTIONS]

Arguments:
  PR_NUMBER    GitHub PR number to review (optional if BUILDKITE_PULL_REQUEST is set)

Options:
  --dry-run    Print suggestions without posting to GitHub
  --help, -h   Show this help message

Environment Variables:
  ANTHROPIC_API_KEY              Use direct Anthropic API (for local testing)
  BUILDKITE_AGENT_ACCESS_TOKEN   Use Buildkite Model Provider (for CI)
  BUILDKITE_PULL_REQUEST         PR number (set automatically in Buildkite PR builds)
  GITHUB_TOKEN                   GitHub token for posting comments (or use 'gh auth login')

Examples:
  # Local testing with dry-run
  ANTHROPIC_API_KEY=sk-... ./pr-review-agent 1120 --dry-run

  # Local testing with GitHub posting
  ANTHROPIC_API_KEY=sk-... ./pr-review-agent 1120

  # In Buildkite CI (automatic PR detection)
  ./pr-review-agent
`)
}

func main() {
	// Check for help flag
	for _, arg := range os.Args[1:] {
		if arg == "--help" || arg == "-h" {
			printUsage()
			os.Exit(0)
		}
	}

	ctx, err := initContext()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		fmt.Fprintf(os.Stderr, "\nRun 'pr-review-agent --help' for usage information.\n")
		os.Exit(1)
	}

	if err := runReview(ctx); err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
}

func initContext() (*ReviewContext, error) {
	ctx := &ReviewContext{
		Repo: defaultRepo,
	}

	// Check for command-line arguments (local testing mode)
	// Usage: pr-review-agent <pr-number> [commit-sha] [--dry-run]
	args := os.Args[1:]
	localMode := false

	for i, arg := range args {
		if arg == "--dry-run" {
			ctx.DryRun = true
		} else if i == 0 {
			ctx.PRNumber = arg
			localMode = true
		} else if i == 1 && !strings.HasPrefix(arg, "--") {
			ctx.CommitSHA = arg
		}
	}

	// Determine API mode
	if os.Getenv("ANTHROPIC_API_KEY") != "" {
		ctx.APIMode = ModeAnthropic
		ctx.APIToken = os.Getenv("ANTHROPIC_API_KEY")
		ctx.APIEndpoint = "https://api.anthropic.com"
		fmt.Println("--- Using Anthropic API directly")
	} else if os.Getenv("BUILDKITE_AGENT_ACCESS_TOKEN") != "" {
		ctx.APIMode = ModeBuildkite
		ctx.APIToken = os.Getenv("BUILDKITE_AGENT_ACCESS_TOKEN")
		ctx.APIEndpoint = os.Getenv("BUILDKITE_AGENT_ENDPOINT")
		if ctx.APIEndpoint == "" {
			return nil, fmt.Errorf("BUILDKITE_AGENT_ENDPOINT is not set")
		}
		fmt.Println("--- Using Buildkite Model Provider")
	} else {
		return nil, fmt.Errorf("no API credentials found. Set ANTHROPIC_API_KEY or BUILDKITE_AGENT_ACCESS_TOKEN")
	}

	// Get PR number - from args, BUILDKITE_PULL_REQUEST env var, metadata, or GitHub query
	if ctx.PRNumber == "" && !localMode {
		// First try BUILDKITE_PULL_REQUEST env var (set when "Build pull requests" is enabled)
		prEnv := os.Getenv("BUILDKITE_PULL_REQUEST")
		if prEnv != "" && prEnv != "false" {
			ctx.PRNumber = prEnv
			fmt.Printf("--- Got PR number from BUILDKITE_PULL_REQUEST: %s\n", ctx.PRNumber)
		} else {
			// Try Buildkite metadata (for manual/input-triggered builds)
			prNum, err := getBuildkiteMetadata("pr_number")
			if err == nil && prNum != "" {
				ctx.PRNumber = prNum
				fmt.Printf("--- Got PR number from Buildkite metadata: %s\n", ctx.PRNumber)
			} else {
				// Fall back to querying GitHub for PR matching the current branch
				branch := os.Getenv("BUILDKITE_BRANCH")
				if branch != "" && branch != "main" {
					prNum, err := getPRForBranch(ctx.Repo, branch)
					if err == nil && prNum != "" {
						ctx.PRNumber = prNum
						fmt.Printf("--- Got PR number from GitHub query (branch: %s): %s\n", branch, ctx.PRNumber)
					}
				}
			}
		}
	}

	if ctx.PRNumber == "" || ctx.PRNumber == "false" {
		return nil, fmt.Errorf("PR number required. Enable 'Build pull requests' in pipeline settings, pass as argument, or set via Buildkite metadata")
	}

	// Skip draft PRs in CI mode (unless running locally)
	if !localMode && os.Getenv("BUILDKITE_PULL_REQUEST_DRAFT") == "true" {
		fmt.Println("--- :memo: Skipping review - PR is still a draft")
		fmt.Println("--- The review will run automatically when the PR is marked ready for review")
		os.Exit(0)
	}

	// Find repo root
	repoRoot, err := findRepoRoot()
	if err != nil {
		return nil, fmt.Errorf("failed to find repo root: %w", err)
	}
	ctx.RepoRoot = repoRoot

	// Load style guide
	styleGuide, err := os.ReadFile(filepath.Join(repoRoot, styleGuideName))
	if err != nil {
		return nil, fmt.Errorf("failed to load style guide: %w", err)
	}
	ctx.StyleGuide = string(styleGuide)

	// Fetch PR diff
	diff, err := fetchPRDiff(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch PR diff: %w", err)
	}
	ctx.PRDiff = diff

	if ctx.DryRun {
		fmt.Println("--- DRY RUN MODE: Will not post to GitHub")
	}

	return ctx, nil
}

func getBuildkiteMetadata(key string) (string, error) {
	cmd := exec.Command("buildkite-agent", "meta-data", "get", key)
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

func getPRForBranch(repo, branch string) (string, error) {
	cmd := exec.Command("gh", "pr", "list", "--repo", repo, "--head", branch, "--json", "number", "--jq", ".[0].number")
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	prNum := strings.TrimSpace(string(out))
	if prNum == "" || prNum == "null" {
		return "", fmt.Errorf("no PR found for branch %s", branch)
	}
	return prNum, nil
}

func findRepoRoot() (string, error) {
	cmd := exec.Command("git", "rev-parse", "--show-toplevel")
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(out)), nil
}

func fetchPRDiff(ctx *ReviewContext) (string, error) {
	fmt.Printf("--- :github: Fetching PR #%s diff\n", ctx.PRNumber)

	if ctx.CommitSHA != "" {
		fmt.Printf("Reviewing specific commit: %s\n", ctx.CommitSHA)

		// Get parent SHA
		cmd := exec.Command("gh", "api", fmt.Sprintf("/repos/%s/commits/%s", ctx.Repo, ctx.CommitSHA),
			"--jq", ".parents[0].sha")
		out, err := cmd.Output()
		if err != nil {
			return "", fmt.Errorf("failed to get parent commit: %w", err)
		}
		parentSHA := strings.TrimSpace(string(out))

		fmt.Printf("Diffing %s..%s\n", parentSHA, ctx.CommitSHA)

		// Get diff between commits
		cmd = exec.Command("gh", "api", fmt.Sprintf("/repos/%s/compare/%s...%s", ctx.Repo, parentSHA, ctx.CommitSHA),
			"--jq", `.files[] | "diff --git a/\(.filename) b/\(.filename)\n--- a/\(.filename)\n+++ b/\(.filename)\n\(.patch // "")"`)
		out, err = cmd.Output()
		if err != nil {
			return "", fmt.Errorf("failed to get commit diff: %w", err)
		}
		return string(out), nil
	}

	fmt.Println("Reviewing full PR diff")
	cmd := exec.Command("gh", "pr", "diff", ctx.PRNumber, "--repo", ctx.Repo)
	out, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to get PR diff: %w", err)
	}
	return string(out), nil
}

func runReview(ctx *ReviewContext) error {
	fmt.Println("--- :robot_face: Starting PR review with tool use")
	fmt.Printf("Model: %s\n", model)

	prompt := buildPrompt(ctx)

	messages := []Message{
		{
			Role: "user",
			Content: []Content{
				{Type: "text", Text: prompt},
			},
		},
	}

	// Tool use loop
	const maxIterations = 50
	emptyResponseCount := 0
	const maxEmptyResponses = 3

	for i := 0; i < maxIterations; i++ {
		resp, err := callAPI(ctx, messages)
		if err != nil {
			return err
		}

		fmt.Printf("--- :information_source: API response (stop_reason: %s, tokens: %d/%d)\n",
			resp.StopReason, resp.Usage.InputTokens, resp.Usage.OutputTokens)

		// Guard against empty/unexpected responses
		if resp.StopReason == "" || (resp.Usage.InputTokens == 0 && resp.Usage.OutputTokens == 0) {
			emptyResponseCount++
			fmt.Printf("--- :warning: Empty or unexpected response (%d/%d)\n", emptyResponseCount, maxEmptyResponses)
			if emptyResponseCount >= maxEmptyResponses {
				fmt.Println("--- :x: Too many empty responses, stopping review")
				break
			}
			continue
		}
		emptyResponseCount = 0

		// Add assistant response to messages
		messages = append(messages, Message{
			Role:    "assistant",
			Content: resp.Content,
		})

		// Check if we're done
		if resp.StopReason == "end_turn" {
			// Print final text response
			for _, c := range resp.Content {
				if c.Type == "text" {
					fmt.Println("\n--- :white_check_mark: Review Complete")
					fmt.Println(c.Text)
				}
			}
			break
		}

		// Handle tool use
		if resp.StopReason == "tool_use" {
			toolResults := []Content{}

			for _, c := range resp.Content {
				if c.Type == "tool_use" {
					result, err := executeTool(ctx, c.Name, c.Input)
					if err != nil {
						result = fmt.Sprintf("Error: %v", err)
					}

					toolResults = append(toolResults, Content{
						Type:      "tool_result",
						ToolUseID: c.ID,
						Content:   result,
					})
				}
			}

			// Add tool results to messages
			messages = append(messages, Message{
				Role:    "user",
				Content: toolResults,
			})
		} else {
			fmt.Printf("--- :warning: Unexpected stop_reason: %s, stopping review\n", resp.StopReason)
			break
		}
	}

	if emptyResponseCount < maxEmptyResponses {
		fmt.Println("--- :information_source: Review loop completed")
	}

	// Post summary comment if there were suggestions
	if len(ctx.Suggestions) > 0 {
		if err := postSummaryComment(ctx); err != nil {
			fmt.Fprintf(os.Stderr, "Warning: failed to post summary comment: %v\n", err)
		}
	}

	return nil
}

func buildPrompt(ctx *ReviewContext) string {
	return fmt.Sprintf(`You are reviewing a pull request for the Buildkite documentation repository.

## Style Guide

The following style guide defines the standards for this documentation:

%s

## Task

Review the PR diff below against the style guide. Focus only on added/changed lines (lines starting with +).

## Instructions

1. Analyze the diff against the style guide rules.
2. For each confirmed violation:
   a. Use get_line_number to find the exact line number in the file
   b. Use submit_suggestion to create a GitHub suggestion for the fix
3. When finished, call finish_review with your verdict and summary.

## Critical Rules

- Only submit suggestions you are 100%% certain about
- If you have ANY doubt about whether something is a violation, DO NOT submit it
- Never submit a suggestion and then say "upon review" or "however" to walk it back
- Never include phrases like "this suggestion is being withdrawn" - just don't submit uncertain suggestions
- Be precise with the replacement text - it will be used as a GitHub suggestion
- Only suggest changes for lines that were added or modified in the PR (lines starting with + in the diff)
- Do not suggest changes for unchanged lines or lines being deleted

## PR #%s Diff

`+"```diff\n%s\n```", ctx.StyleGuide, ctx.PRNumber, ctx.PRDiff)
}

func callAPI(ctx *ReviewContext, messages []Message) (*Response, error) {
	reqBody := Request{
		Model:     model,
		MaxTokens: maxTokens,
		Tools:     tools,
		Messages:  messages,
	}

	jsonBody, err := json.Marshal(reqBody)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal request: %w", err)
	}

	// Determine URL based on API mode
	var url string
	if ctx.APIMode == ModeAnthropic {
		url = "https://api.anthropic.com/v1/messages"
	} else {
		url = fmt.Sprintf("%s/ai/anthropic/v1/messages", ctx.APIEndpoint)
	}

	req, err := http.NewRequest("POST", url, bytes.NewReader(jsonBody))
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("x-api-key", ctx.APIToken)
	req.Header.Set("anthropic-version", anthropicVer)

	client := &http.Client{
		Timeout: 5 * time.Minute,
	}
	resp, err := client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("API request failed: %w", err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response: %w", err)
	}

	// Check HTTP status code
	if resp.StatusCode != http.StatusOK {
		// Try to parse error from body
		var apiResp Response
		if err := json.Unmarshal(body, &apiResp); err == nil && apiResp.Error != nil {
			return nil, fmt.Errorf("API error (HTTP %d): %s - %s", resp.StatusCode, apiResp.Error.Type, apiResp.Error.Message)
		}
		return nil, fmt.Errorf("API request failed with HTTP %d: %s", resp.StatusCode, string(body))
	}

	var apiResp Response
	if err := json.Unmarshal(body, &apiResp); err != nil {
		return nil, fmt.Errorf("failed to parse response: %w\nBody: %s", err, string(body))
	}

	if apiResp.Error != nil {
		return nil, fmt.Errorf("API error: %s - %s", apiResp.Error.Type, apiResp.Error.Message)
	}

	return &apiResp, nil
}

func executeTool(ctx *ReviewContext, name string, input any) (string, error) {
	inputMap, ok := input.(map[string]any)
	if !ok {
		return "", fmt.Errorf("invalid input type")
	}

	switch name {
	case "get_line_number":
		return toolGetLineNumber(ctx, inputMap)
	case "submit_suggestion":
		return toolSubmitSuggestion(ctx, inputMap)
	case "finish_review":
		return toolFinishReview(ctx, inputMap)
	default:
		return "", fmt.Errorf("unknown tool: %s", name)
	}
}

func toolGetLineNumber(ctx *ReviewContext, input map[string]any) (string, error) {
	file, _ := input["file"].(string)
	searchText, _ := input["search_text"].(string)

	fmt.Printf("  → get_line_number: %s (searching for: %.50s...)\n", file, searchText)

	filePath := filepath.Join(ctx.RepoRoot, file)
	f, err := os.Open(filePath)
	if err != nil {
		return "", fmt.Errorf("failed to open file: %w", err)
	}
	defer f.Close()

	scanner := bufio.NewScanner(f)
	lineNum := 0
	for scanner.Scan() {
		lineNum++
		if strings.Contains(scanner.Text(), searchText) {
			return fmt.Sprintf(`{"line": %d, "text": %q}`, lineNum, scanner.Text()), nil
		}
	}

	return `{"error": "text not found in file"}`, nil
}

func toolSubmitSuggestion(ctx *ReviewContext, input map[string]any) (string, error) {
	file, _ := input["file"].(string)
	line, _ := input["line"].(float64)
	original, _ := input["original"].(string)
	replacement, _ := input["replacement"].(string)
	reason, _ := input["reason"].(string)

	fmt.Printf("  → submit_suggestion: %s:%d\n", file, int(line))
	fmt.Printf("    Reason: %s\n", reason)

	suggestion := Suggestion{
		File:        file,
		Line:        int(line),
		Original:    original,
		Replacement: replacement,
		Reason:      reason,
	}

	// Post the suggestion as a PR review comment
	err := postSuggestionComment(ctx, suggestion)
	if err != nil {
		// Log the error so we can see it in build output
		fmt.Printf("    ⚠️  Failed to post suggestion: %v\n", err)
		return fmt.Sprintf(`{"success": false, "error": %q}`, err.Error()), nil
	}

	ctx.Suggestions = append(ctx.Suggestions, suggestion)
	fmt.Printf("    ✓ Suggestion posted successfully\n")
	return `{"success": true}`, nil
}

func toolFinishReview(ctx *ReviewContext, input map[string]any) (string, error) {
	verdict, _ := input["verdict"].(string)
	summary, _ := input["summary"].(string)
	suggestionCount, _ := input["suggestion_count"].(float64)

	fmt.Printf("  → finish_review: %s (%d suggestions)\n", verdict, int(suggestionCount))
	fmt.Printf("    Summary: %s\n", summary)

	return fmt.Sprintf(`{"verdict": %q, "recorded": true}`, verdict), nil
}

func postSuggestionComment(ctx *ReviewContext, s Suggestion) error {
	// Build the comment body with suggestion block
	body := fmt.Sprintf("%s\n\n```suggestion\n%s\n```", s.Reason, s.Replacement)

	// In dry-run mode, just print what would be posted
	if ctx.DryRun {
		fmt.Printf("    [DRY RUN] Would post suggestion to %s:%d\n", s.File, s.Line)
		fmt.Printf("    Body: %s\n", body)
		return nil
	}

	commitSHA := getLatestCommit(ctx)
	if commitSHA == "" {
		return fmt.Errorf("could not determine commit SHA for PR")
	}

	// Build the request body as proper JSON
	requestBody := map[string]interface{}{
		"commit_id": commitSHA,
		"event":     "COMMENT",
		"comments": []map[string]interface{}{
			{
				"path": s.File,
				"line": s.Line,
				"side": "RIGHT",
				"body": body,
			},
		},
	}

	jsonBody, err := json.Marshal(requestBody)
	if err != nil {
		return fmt.Errorf("failed to marshal request: %w", err)
	}

	// Use gh api with --input to pass JSON via stdin
	cmd := exec.Command("gh", "api",
		"--method", "POST",
		fmt.Sprintf("/repos/%s/pulls/%s/reviews", ctx.Repo, ctx.PRNumber),
		"--input", "-",
	)
	cmd.Stdin = strings.NewReader(string(jsonBody))

	output, err := cmd.CombinedOutput()
	if err != nil {
		return fmt.Errorf("gh api failed: %w\nOutput: %s", err, string(output))
	}

	return nil
}

func getLatestCommit(ctx *ReviewContext) string {
	if ctx.CommitSHA != "" {
		return ctx.CommitSHA
	}

	// Get the latest commit from the PR
	cmd := exec.Command("gh", "pr", "view", ctx.PRNumber, "--repo", ctx.Repo, "--json", "headRefOid", "--jq", ".headRefOid")
	out, err := cmd.Output()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(string(out))
}

func postSummaryComment(ctx *ReviewContext) error {
	if len(ctx.Suggestions) == 0 {
		return nil
	}

	var sb strings.Builder
	sb.WriteString("## 🤖 Automated Style Review\n\n")
	sb.WriteString(fmt.Sprintf("Found **%d** style suggestion(s). ", len(ctx.Suggestions)))
	sb.WriteString("Review the inline suggestions above and click **Commit suggestion** to apply any you agree with.\n\n")
	sb.WriteString("### Summary of suggestions:\n\n")

	for i, s := range ctx.Suggestions {
		sb.WriteString(fmt.Sprintf("%d. `%s:%d` - %s\n", i+1, s.File, s.Line, s.Reason))
	}

	sb.WriteString(fmt.Sprintf("\n---\n_This review was generated by PR Review Agent using Claude %s._", model))

	// In dry-run mode, just print the summary
	if ctx.DryRun {
		fmt.Println("\n[DRY RUN] Would post summary comment:")
		fmt.Println(sb.String())
		return nil
	}

	cmd := exec.Command("gh", "pr", "comment", ctx.PRNumber, "--repo", ctx.Repo, "--body", sb.String())
	return cmd.Run()
}

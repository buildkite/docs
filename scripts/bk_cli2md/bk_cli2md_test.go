package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestGeneratedSubcommandRetainsGuidanceAndRepeatableFlags(t *testing.T) {
	binary := filepath.Join(t.TempDir(), "bk")
	help := `Usage: bk build list [flags]

List builds.

Filters apply to the selected pipeline.
Specify --pipeline when selection is ambiguous.

Flags:
      --message=STRING                 Filter by message
      --meta-data=KEY=VALUE;...         Filter by build meta-data
      --limit=50                       Maximum number of builds

Examples:
  $ bk build view -b feature-y
  $ bk build cancel 123 -pipeline my-pipeline --web
  $ bk pipeline list --repo my-repo
  $ bk pipeline list --name pipeline | xargs -I {} bk build list --pipeline {} --since 48h --duration 1h
`
	if err := os.WriteFile(binary, []byte("#!/bin/sh\ncat <<'EOF'\n"+help+"EOF\n"), 0755); err != nil {
		t.Fatal(err)
	}
	originalArgs := os.Args
	os.Args = []string{"bk_cli2md", binary}
	t.Cleanup(func() { os.Args = originalArgs })

	markdown := generateMarkdown(&Command{
		Name:        "build",
		Subcommands: []Subcommand{{Name: "build list", Description: "List builds."}},
	})
	for _, want := range []string{
		"List builds.\n\nFilters apply to the selected pipeline.\nSpecify --pipeline when selection is ambiguous.",
		"| `--message=STRING` | Filter by message |",
		"| `--meta-data=KEY=VALUE;...` | Filter by build meta-data |",
		"| `--limit=50` | Maximum number of builds |",
		"bk build view -b feature-x",
		"bk build cancel 123 --pipeline my-pipeline --web",
		"bk pipeline list --repository my-repo",
		"bk pipeline list --name pipeline --json | jq -r '.[].slug' | xargs -I {} bk build list --pipeline {} --since 48h --duration '>1h'",
	} {
		if !strings.Contains(markdown, want) {
			t.Errorf("generated Markdown is missing %q", want)
		}
	}
}

func TestCombinedDescriptionRemovesRepeatedFirstSentence(t *testing.T) {
	cmd := &Command{
		Description: "Open Buildkite resources in a web browser",
		LongDesc:    "Open Buildkite resources in your web browser. Without arguments, the pipeline for the current project is resolved and opened.",
	}

	got := combinedDescription(cmd)
	want := "Open Buildkite resources in your web browser. Without arguments, the pipeline for the current project is resolved and opened."

	if got != want {
		t.Fatalf("combinedDescription() = %q, want %q", got, want)
	}
}

func TestCombinedDescriptionKeepsDistinctDescription(t *testing.T) {
	cmd := &Command{
		Description: "Open Buildkite resources in a web browser",
		LongDesc:    "Without arguments, the pipeline for the current project is resolved and opened.",
	}

	got := combinedDescription(cmd)
	want := "Open Buildkite resources in a web browser\n\nWithout arguments, the pipeline for the current project is resolved and opened."

	if got != want {
		t.Fatalf("combinedDescription() = %q, want %q", got, want)
	}
}

func TestParseHelpHandlesNegatableFlags(t *testing.T) {
	help := `Usage: bk team create <name> [flags]

Create a new team.

Flags:
      --default-member-role="member"
                              Default role for new members
      --[no-]members-can-create-pipelines
                              Whether members can create pipelines
`

	cmd := parseHelp(help, "team create")
	if len(cmd.Flags) != 2 {
		t.Fatalf("len(cmd.Flags) = %d, want 2", len(cmd.Flags))
	}
	if got, want := cmd.Flags[1].Long, "[no-]members-can-create-pipelines"; got != want {
		t.Fatalf("cmd.Flags[1].Long = %q, want %q", got, want)
	}
	if got, want := cmd.Flags[1].Description, "Whether members can create pipelines"; got != want {
		t.Fatalf("cmd.Flags[1].Description = %q, want %q", got, want)
	}
}

func TestGetSubcommandTitlePreservesInitialisms(t *testing.T) {
	tests := map[string]string{
		"job ssh":                 "Connect to a job using SSH",
		"job vnc":                 "Connect to a job using VNC",
		"team update":             "Update a team",
		"team delete":             "Delete a team",
		"build retry-failed-jobs": "Retry failed jobs",
		"build step-uploads":      "List dynamic step uploads",
		// Nested commands use every word before the action as the noun.
		"cache registry list":                   "List cache registries",
		"cache registry view":                   "View a cache registry",
		"cache registry update":                 "Update a cache registry",
		"cache registry delete":                 "Delete a cache registry",
		"secret migrate github-actions prepare": "Prepare a GitHub Actions secret migration",
		"secret migrate github-actions run":     "Run a GitHub Actions secret migration",
	}

	for name, want := range tests {
		t.Run(name, func(t *testing.T) {
			if got := getSubcommandTitle(name); got != want {
				t.Fatalf("getSubcommandTitle(%q) = %q, want %q", name, got, want)
			}
		})
	}
}

func TestNormalizeMarkdownUsesOneTrailingNewline(t *testing.T) {
	got := normalizeMarkdown("# Page title\n\n")
	want := "# Page title\n"

	if got != want {
		t.Fatalf("normalizeMarkdown() = %q, want %q", got, want)
	}
}

func TestFormatDescriptionFormatsCommandLineExamples(t *testing.T) {
	got := formatDescription("Filter artifacts by path, e.g. --path \"log/test_report*.json\". Requires read_builds and `read_artifacts`.")
	want := "Filter artifacts by path, for example `--path \"log/test_report*.json\"`. Requires `read_builds` and `read_artifacts`."

	if got != want {
		t.Fatalf("formatDescription() = %q, want %q", got, want)
	}
}

func TestFormatDescriptionFormatsStdinMarker(t *testing.T) {
	got := formatDescription("Read the secret value from a file, or from stdin with -. Content is preserved exactly.")
	want := "Read the secret value from a file, or from stdin with `-`. Content is preserved exactly."

	if got != want {
		t.Fatalf("formatDescription() = %q, want %q", got, want)
	}
}

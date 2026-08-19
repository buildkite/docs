package main

import "testing"

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
	want := "Open Buildkite resources in a web browser Without arguments, the pipeline for the current project is resolved and opened."

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
		"job ssh":     "Connect to a job using SSH",
		"job vnc":     "Connect to a job using VNC",
		"team update": "Update a team",
		"team delete": "Delete a team",
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
	got := formatDescription(`Filter artifacts by path. Supports exact matches and glob patterns using * as a wildcard, e.g. --path "log/rspec*.json".`)
	want := "Filter artifacts by path. Supports exact matches and glob patterns using * as a wildcard, for example `--path \"log/rspec*.json\"`."

	if got != want {
		t.Fatalf("formatDescription() = %q, want %q", got, want)
	}
}

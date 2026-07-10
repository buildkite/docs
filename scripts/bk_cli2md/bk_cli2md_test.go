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

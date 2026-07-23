package main

import "testing"

func TestExtractEnvVarsIgnoresBracketedDescriptionText(t *testing.T) {
	line := "  --checkout-override-mode value  One of [strict from-job none]. (default: \"from-job\") [$BUILDKITE_CHECKOUT_OVERRIDE_MODE]"

	got := extractEnvVars(line)
	want := "$BUILDKITE_CHECKOUT_OVERRIDE_MODE"
	if got != want {
		t.Fatalf("extractEnvVars() = %q, want %q", got, want)
	}
}

func TestExtractEnvVarsHandlesMultipleTrailingAnnotations(t *testing.T) {
	line := "  --apply-if-changed value  Apply changes [$BUILDKITE_AGENT_APPLY_IF_CHANGED, $BUILDKITE_AGENT_APPLY_SKIP_IF_UNCHANGED]"

	got := extractEnvVars(line)
	want := "$BUILDKITE_AGENT_APPLY_IF_CHANGED\n      $BUILDKITE_AGENT_APPLY_SKIP_IF_UNCHANGED"
	if got != want {
		t.Fatalf("extractEnvVars() = %q, want %q", got, want)
	}
}

func TestNormalizeDescriptionUsesDocsStyleForCheckoutOverrideMode(t *testing.T) {
	desc := "′from-job′ matches the earlier agent behaviour"

	got := normalizeDescription("checkout-override-mode", desc)
	want := "'from-job' matches the earlier agent behavior"
	if got != want {
		t.Fatalf("normalizeDescription() = %q, want %q", got, want)
	}
}

func TestNormalizeDescriptionUsesAgentTokenTerminology(t *testing.T) {
	desc := "Your cluster token or unclustered registration token. Prefix with file:// to read the token from a file"

	got := normalizeDescription("token", desc)
	want := "Your agent token. Prefix with file:// to read the token from a file"
	if got != want {
		t.Fatalf("normalizeDescription() = %q, want %q", got, want)
	}
}

package main

import "testing"

func TestExtractEnvVarPrefersTrailingAnnotation(t *testing.T) {
	desc := "Names must match --redacted-vars or $BUILDKITE_REDACTED_VARS. [$BUILDKITE_AGENT_REDACT_VARS_FILTER]"

	envVar, cleaned := extractEnvVar(desc)

	if envVar != "$BUILDKITE_AGENT_REDACT_VARS_FILTER" {
		t.Fatalf("envVar = %q, want %q", envVar, "$BUILDKITE_AGENT_REDACT_VARS_FILTER")
	}
	if cleaned != "Names must match --redacted-vars or $BUILDKITE_REDACTED_VARS." {
		t.Fatalf("cleaned = %q", cleaned)
	}
}

func TestExtractEnvVarHandlesMultipleTrailingAnnotations(t *testing.T) {
	desc := "Apply if_changed configuration. [$BUILDKITE_AGENT_APPLY_IF_CHANGED, $BUILDKITE_AGENT_APPLY_SKIP_IF_UNCHANGED]"

	envVar, cleaned := extractEnvVar(desc)

	want := "$BUILDKITE_AGENT_APPLY_IF_CHANGED, $BUILDKITE_AGENT_APPLY_SKIP_IF_UNCHANGED"
	if envVar != want {
		t.Fatalf("envVar = %q, want %q", envVar, want)
	}
	if cleaned != "Apply if_changed configuration." {
		t.Fatalf("cleaned = %q", cleaned)
	}
}

func TestExtractEnvVarFallsBackToProseEnvVar(t *testing.T) {
	desc := "Endpoint defaults to $BUILDKITE_AGENT_ENDPOINT"

	envVar, cleaned := extractEnvVar(desc)

	if envVar != "$BUILDKITE_AGENT_ENDPOINT" {
		t.Fatalf("envVar = %q, want %q", envVar, "$BUILDKITE_AGENT_ENDPOINT")
	}
	if cleaned != desc {
		t.Fatalf("cleaned = %q, want %q", cleaned, desc)
	}
}

func TestNormalizeFlagDescriptionReplacesDynamicArtifactUploadConcurrencyDefault(t *testing.T) {
	desc := "Number of concurrent artifact upload operations (default: 15)"

	got := normalizeFlagDescription("concurrency", desc)
	want := "Number of concurrent artifact upload operations (default: current <code>GOMAXPROCS</code> value)"

	if got != want {
		t.Fatalf("normalizeFlagDescription() = %q, want %q", got, want)
	}
}

func TestNormalizeFlagDescriptionKeepsOtherConcurrencyDescriptions(t *testing.T) {
	desc := "Maximum number of concurrent cache operations (default: 15)"

	got := normalizeFlagDescription("concurrency", desc)

	if got != desc {
		t.Fatalf("normalizeFlagDescription() = %q, want %q", got, desc)
	}
}

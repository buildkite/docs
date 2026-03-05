package main

// commandDescriptions lists all bk CLI commands that should be documented,
// along with their human-readable descriptions used in the generated
// Markdown page introductions. When a new command is added to the CLI,
// add it here to include it in the generated documentation.
var commandDescriptions = map[string]string{
	"agent":        "manage Buildkite agents",
	"api":          "interact with the Buildkite API",
	"artifacts":    "manage build artifacts",
	"auth":         "manage authorization",
	"build":        "manage pipeline builds",
	"cluster":      "manage Buildkite organization clusters",
	"config":       "manage configurations",
	"configure":    "configure your Buildkite CLI settings",
	"init":         "initialize a pipeline file with Buildkite Pipelines",
	"job":          "manage jobs within builds",
	"organization": "manage Buildkite organizations",
	"package":      "manage packages",
	"pipeline":     "manage pipelines",
	"use":          "choose which Buildkite organization to work with",
	"user":         "manage users in your Buildkite organization",
	"version":      "display which version of the Buildkite CLI you're using",
	"whoami":       "display information about the current user's Buildkite organization and API token",
}

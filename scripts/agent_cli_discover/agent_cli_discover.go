package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// Commands that should never get documentation pages.
var skipCommands = map[string]bool{
	"help":                   true,
	"h":                      true,
	"acknowledgements":       true,
	"kubernetes-bootstrap":   true,
	"git-credentials-helper": true,
}

// topLevelCommand represents a command parsed from agent --help.
type topLevelCommand struct {
	name        string
	description string
	subcommands []subcommand // empty for leaf commands
	category    string       // "available", "job", "internal"
}

type subcommand struct {
	name        string
	description string
}

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintf(os.Stderr, "Usage: %s <agent-binary> <repo-root> [--list-leaf-commands]\n", os.Args[0])
		os.Exit(1)
	}

	binary := os.Args[1]
	repoRoot := os.Args[2]
	listOnly := len(os.Args) > 3 && os.Args[3] == "--list-leaf-commands"

	// discoverAll runs agent --help and probes each command for subcommands.
	// We capture the top-level help text for reuse by updateReferenceMd.
	topHelpText, commands, err := discoverAll(binary)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error discovering commands: %v\n", err)
		os.Exit(1)
	}

	// In both modes, output the leaf command list to stdout.
	// Full mode uses stderr for status; the shell script reads stdout.
	for _, leaf := range buildLeafList(commands) {
		fmt.Println(leaf)
	}

	if listOnly {
		return
	}

	// Full mode: scaffold new files, update nav and reference page
	scaffoldNewCommands(repoRoot, commands)
	warnRemovedCommands(repoRoot, commands)

	navPath := filepath.Join(repoRoot, "data", "nav.yml")
	if err := updateNavYml(navPath, commands); err != nil {
		fmt.Fprintf(os.Stderr, "Error updating %s: %v\n", navPath, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "  Updated %s\n", navPath)

	refPath := filepath.Join(repoRoot, "pages", "agent", "cli", "reference.md")
	if err := updateReferenceMd(refPath, topHelpText, commands); err != nil {
		fmt.Fprintf(os.Stderr, "Error updating %s: %v\n", refPath, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "  Updated %s\n", refPath)
}

// discoverAll parses agent --help and then probes each command for subcommands.
// Returns the raw top-level help text (for reuse) and the parsed command list.
func discoverAll(binary string) (string, []topLevelCommand, error) {
	helpText, err := runHelp(binary)
	if err != nil {
		return "", nil, fmt.Errorf("running %s --help: %w", binary, err)
	}

	toplevel := parseTopLevelHelp(helpText)

	for i, cmd := range toplevel {
		subs, err := discoverSubcommands(binary, cmd.name)
		if err != nil {
			fmt.Fprintf(os.Stderr, "  [WARN] Could not probe subcommands for %s: %v\n", cmd.name, err)
			continue
		}
		toplevel[i].subcommands = subs
	}

	return helpText, toplevel, nil
}

// runHelp executes the binary with --help and returns the output.
// urfave/cli exits non-zero on --help, so we ignore the error when output is present.
func runHelp(binary string, args ...string) (string, error) {
	cmdArgs := append([]string{}, args...)
	cmdArgs = append(cmdArgs, "--help")
	cmd := exec.Command(binary, cmdArgs...)
	out, err := cmd.CombinedOutput()
	if err != nil && len(out) == 0 {
		return "", err
	}
	return string(out), nil
}

// commandLineRE matches command listing lines: 2+ spaces, then a lowercase name.
var commandLineRE = regexp.MustCompile(`^\s{2,}([a-z][-a-z]*(?:,\s*[a-z]+)?)\s{2,}(.+)$`)

// shouldSkip checks if a comma-separated name field contains any command in the skip list.
func shouldSkip(nameField string) bool {
	for _, n := range strings.Split(nameField, ",") {
		if skipCommands[strings.TrimSpace(n)] {
			return true
		}
	}
	return false
}

// parseTopLevelHelp extracts commands from the agent --help output.
func parseTopLevelHelp(helpText string) []topLevelCommand {
	lines := strings.Split(helpText, "\n")

	var commands []topLevelCommand
	category := "available"

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if strings.HasSuffix(trimmed, ":") && !strings.HasPrefix(trimmed, "-") {
			lower := strings.ToLower(trimmed)
			switch {
			case strings.Contains(lower, "within a buildkite job") || strings.Contains(lower, "within a job"):
				category = "job"
			case strings.Contains(lower, "internal"):
				category = "internal"
			case strings.Contains(lower, "available commands"):
				category = "available"
			}
			continue
		}

		m := commandLineRE.FindStringSubmatch(line)
		if m == nil {
			continue
		}

		nameField := m[1]
		if shouldSkip(nameField) {
			continue
		}

		commands = append(commands, topLevelCommand{
			name:        strings.TrimSpace(strings.Split(nameField, ",")[0]),
			description: strings.TrimSpace(m[2]),
			category:    category,
		})
	}

	return commands
}

// discoverSubcommands runs agent <cmd> --help and parses the COMMANDS section.
func discoverSubcommands(binary, cmdName string) ([]subcommand, error) {
	helpText, err := runHelp(binary, cmdName)
	if err != nil {
		return nil, err
	}

	lines := strings.Split(helpText, "\n")
	inCommands := false
	var subs []subcommand

	for _, line := range lines {
		trimmed := strings.TrimSpace(line)

		// urfave/cli uses "Available commands are:" for subcommand listings;
		// also handle "COMMANDS:" and "Commands:" for other CLI frameworks
		if trimmed == "COMMANDS:" || trimmed == "Commands:" ||
			strings.HasPrefix(trimmed, "Available commands are") ||
			strings.HasPrefix(trimmed, "Available subcommands are") {
			inCommands = true
			continue
		}

		if !inCommands {
			continue
		}

		if trimmed == "" {
			continue
		}
		if strings.HasSuffix(trimmed, ":") && !strings.HasPrefix(trimmed, "-") {
			break
		}

		m := commandLineRE.FindStringSubmatch(line)
		if m == nil {
			continue
		}

		nameField := m[1]
		if shouldSkip(nameField) {
			continue
		}

		subs = append(subs, subcommand{
			name:        strings.TrimSpace(strings.Split(nameField, ",")[0]),
			description: strings.TrimSpace(m[2]),
		})
	}

	return subs, nil
}

// buildLeafList returns the flat list of leaf commands for help generation.
func buildLeafList(commands []topLevelCommand) []string {
	var leaves []string
	for _, cmd := range commands {
		if len(cmd.subcommands) == 0 {
			leaves = append(leaves, cmd.name)
		} else {
			for _, sub := range cmd.subcommands {
				leaves = append(leaves, cmd.name+" "+sub.name)
			}
		}
	}
	return leaves
}

// toSnake converts a command name to snake_case for filenames.
func toSnake(s string) string {
	return strings.NewReplacer("-", "_", " ", "_").Replace(s)
}

func refPagePath(repoRoot, cmdName string) string {
	return filepath.Join(repoRoot, "pages", "agent", "cli", "reference", toSnake(cmdName)+".md")
}

func helpFilePath(repoRoot, leafCommand string) string {
	return filepath.Join(repoRoot, "pages", "agent", "cli", "help", "_"+toSnake(leafCommand)+".md")
}

// scaffoldNewCommands creates placeholder files for newly discovered commands.
func scaffoldNewCommands(repoRoot string, commands []topLevelCommand) {
	for _, cmd := range commands {
		refPath := refPagePath(repoRoot, cmd.name)
		if _, err := os.Stat(refPath); err == nil {
			// Reference page exists — check for new subcommands
			for _, sub := range cmd.subcommands {
				hp := helpFilePath(repoRoot, cmd.name+" "+sub.name)
				if _, err := os.Stat(hp); err != nil {
					createHelpPlaceholder(hp)
					fmt.Fprintf(os.Stderr, "  [WARN] New subcommand '%s %s': help file created at %s\n", cmd.name, sub.name, hp)
					fmt.Fprintf(os.Stderr, "         Manual update needed: add <%%= render 'agent/cli/help/%s_%s' %%> to %s\n",
						toSnake(cmd.name), toSnake(sub.name), refPath)
				}
			}
			continue
		}

		// New top-level command — create everything
		createReferencePage(refPath, cmd)
		helpCount := 0
		if len(cmd.subcommands) == 0 {
			hp := helpFilePath(repoRoot, cmd.name)
			createHelpPlaceholder(hp)
			helpCount = 1
		} else {
			for _, sub := range cmd.subcommands {
				hp := helpFilePath(repoRoot, cmd.name+" "+sub.name)
				createHelpPlaceholder(hp)
				helpCount++
			}
		}
		fmt.Fprintf(os.Stderr, "  [NEW] %s: created reference page and %d help file(s)\n", cmd.name, helpCount)
	}
}

// createReferencePage generates a placeholder reference page for a new command.
func createReferencePage(path string, cmd topLevelCommand) {
	var b strings.Builder

	b.WriteString(fmt.Sprintf("# buildkite-agent %s\n\n", cmd.name))

	if len(cmd.subcommands) == 0 {
		b.WriteString(fmt.Sprintf("The Buildkite agent's `%s` command is used to %s.\n\n", cmd.name, lowercaseFirst(cmd.description)))
		b.WriteString("## Usage\n\n")
		b.WriteString(fmt.Sprintf("<%%= render 'agent/cli/help/%s' %%>\n", toSnake(cmd.name)))
	} else {
		b.WriteString(fmt.Sprintf("The Buildkite agent's `%s` subcommands provide the ability to %s.\n\n", cmd.name, lowercaseFirst(cmd.description)))
		for _, sub := range cmd.subcommands {
			b.WriteString(fmt.Sprintf("## %s\n\n", capitalizeFirst(sub.name)))
			b.WriteString(fmt.Sprintf("<%%= render 'agent/cli/help/%s_%s' %%>\n\n", toSnake(cmd.name), toSnake(sub.name)))
		}
	}

	if err := os.WriteFile(path, []byte(b.String()), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "    Error writing %s: %v\n", path, err)
	}
}

const helpHeader = `<!--

 _____           ______                _______    _ _
(____ \         |  ___ \       _      (_______)  | (_)_
 _   \ \ ___    | |   | | ___ | |_     _____   _ | |_| |_
| |   | / _ \   | |   | |/ _ \|  _)   |  ___) / || | |  _)
| |__/ / |_| |  | |   | | |_| | |__   | |____( (_| | | |__
|_____/ \___/   |_|   |_|\___/ \___)  |_______)____|_|\___)

This file is auto-generated by scripts/update-agent-help.sh.

Instead of directly changing this file, you must:

1. Update the agent CLI help content in https://github.com/buildkite/agent (not in this repo)
2. From the root of your docs repo, run ./scripts/update-agent-help.sh

-->

`

// createHelpPlaceholder creates a minimal help partial file.
func createHelpPlaceholder(path string) {
	if err := os.WriteFile(path, []byte(helpHeader), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "    Error writing %s: %v\n", path, err)
	}
}

// warnRemovedCommands checks for reference pages that no longer match a discovered command.
func warnRemovedCommands(repoRoot string, commands []topLevelCommand) {
	discovered := make(map[string]bool)
	for _, cmd := range commands {
		discovered[toSnake(cmd.name)] = true
	}

	refDir := filepath.Join(repoRoot, "pages", "agent", "cli", "reference")
	entries, err := os.ReadDir(refDir)
	if err != nil {
		return
	}

	for _, entry := range entries {
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".md") {
			continue
		}
		name := strings.TrimSuffix(entry.Name(), ".md")
		if !discovered[name] {
			fmt.Fprintf(os.Stderr, "  [WARN] Command '%s' no longer in agent binary. Consider removing %s\n",
				name, filepath.Join(refDir, entry.Name()))
		}
	}
}

const navComment = "# Auto-generated by scripts/agent_cli_discover — do not edit manually"

// updateNavYml replaces the auto-generated command entries under
// "Command-line reference" in nav.yml.
func updateNavYml(path string, commands []topLevelCommand) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	lines := strings.Split(string(data), "\n")

	markerIdx := -1
	for i, line := range lines {
		if strings.TrimSpace(line) == navComment {
			markerIdx = i
			break
		}
	}
	if markerIdx == -1 {
		return fmt.Errorf("could not find auto-generated comment marker in nav.yml;\nadd this line inside the 'Command-line reference' children block, between the Overview entry and the first command entry:\n            %s", navComment)
	}

	// Consume existing command entries after the marker (pairs of name + path lines)
	entriesStart := markerIdx + 1
	entriesEnd := entriesStart
	for entriesEnd < len(lines) {
		trimmed := strings.TrimSpace(lines[entriesEnd])
		if !strings.HasPrefix(trimmed, `- name: "`) {
			break
		}
		if entriesEnd+1 >= len(lines) {
			break
		}
		nextTrimmed := strings.TrimSpace(lines[entriesEnd+1])
		if !strings.HasPrefix(nextTrimmed, `path: "agent/cli/reference/`) {
			break
		}
		entriesEnd += 2
	}

	documented := documentedCommands(commands)

	var newEntries []string
	for _, name := range documented {
		newEntries = append(newEntries,
			fmt.Sprintf(`            - name: "%s"`, name),
			fmt.Sprintf(`              path: "agent/cli/reference/%s"`, name),
		)
	}

	var result []string
	result = append(result, lines[:entriesStart]...)
	result = append(result, newEntries...)
	result = append(result, lines[entriesEnd:]...)

	return os.WriteFile(path, []byte(strings.Join(result, "\n")), 0644)
}

// documentedCommands returns top-level command names sorted with
// "start" first, then alphabetical, then "tool" last.
func documentedCommands(commands []topLevelCommand) []string {
	var names []string
	for _, cmd := range commands {
		names = append(names, cmd.name)
	}

	sort.SliceStable(names, func(i, j int) bool {
		if names[i] == "start" {
			return true
		}
		if names[j] == "start" {
			return false
		}
		if names[i] == "tool" {
			return false
		}
		if names[j] == "tool" {
			return true
		}
		return names[i] < names[j]
	})

	return names
}

const (
	refBeginMarker = "<!-- BEGIN auto-generated agent help overview -->"
	refEndMarker   = "<!-- END auto-generated agent help overview -->"
)

// updateReferenceMd regenerates the command listing block in reference.md
// from the agent --help output.
func updateReferenceMd(path, helpText string, commands []topLevelCommand) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	lines := strings.Split(string(data), "\n")

	beginIdx := -1
	endIdx := -1
	for i, line := range lines {
		if strings.TrimSpace(line) == refBeginMarker {
			beginIdx = i
		}
		if strings.TrimSpace(line) == refEndMarker {
			endIdx = i
		}
	}
	if beginIdx == -1 || endIdx == -1 || endIdx <= beginIdx {
		return fmt.Errorf("could not find sentinel markers in reference.md;\nadd these markers around the <div> block:\n%s\n...\n%s", refBeginMarker, refEndMarker)
	}

	// Build hasRefPage from the command list (every command has a ref page after scaffolding)
	hasRefPage := make(map[string]bool)
	for _, cmd := range commands {
		hasRefPage[toSnake(cmd.name)] = true
	}

	overviewBlock := generateOverviewBlock(helpText, hasRefPage)

	var result []string
	result = append(result, lines[:beginIdx]...)
	result = append(result, overviewBlock...)
	result = append(result, lines[endIdx+1:]...)

	return os.WriteFile(path, []byte(strings.Join(result, "\n")), 0644)
}

// generateOverviewBlock builds the HTML block for reference.md from --help output.
func generateOverviewBlock(helpText string, hasRefPage map[string]bool) []string {
	var block []string
	block = append(block, refBeginMarker)
	block = append(block, `<div class="highlight">`)
	block = append(block, `  <pre class="highlight shell"><code>$ buildkite-agent --help`)

	helpLines := strings.Split(strings.TrimRight(helpText, "\n"), "\n")
	for _, line := range helpLines {
		processed := processOverviewLine(line, hasRefPage)
		block = append(block, strings.TrimRight(processed, " \t"))
	}

	block = append(block, `</code></pre>`)
	block = append(block, `</div>`)
	block = append(block, refEndMarker)
	return block
}

// commandInLineRE matches a command name at the start of a command listing line.
var commandInLineRE = regexp.MustCompile(`^(\s{2,})([a-z][-a-z]*(?:,\s*[a-z]+)?)(\s{2,}.*)$`)

// processOverviewLine takes a single line from --help and wraps known commands in <a> tags.
func processOverviewLine(line string, hasRefPage map[string]bool) string {
	m := commandInLineRE.FindStringSubmatch(line)
	if m == nil {
		return escapeHTML(line)
	}

	indent := m[1]
	nameField := m[2]
	rest := m[3]

	primaryName := strings.TrimSpace(strings.Split(nameField, ",")[0])

	if hasRefPage[toSnake(primaryName)] {
		return indent + `<a href="/docs/agent/cli/reference/` + primaryName + `">` + nameField + `</a>` + escapeHTML(rest)
	}

	return escapeHTML(line)
}

// escapeHTML escapes &, < and > for use inside <pre> blocks.
func escapeHTML(s string) string {
	s = strings.ReplaceAll(s, "&", "&amp;")
	s = strings.ReplaceAll(s, "<", "&lt;")
	s = strings.ReplaceAll(s, ">", "&gt;")
	return s
}

func lowercaseFirst(s string) string {
	if len(s) == 0 {
		return s
	}
	return strings.ToLower(string(s[0])) + s[1:]
}

func capitalizeFirst(s string) string {
	if len(s) == 0 {
		return s
	}
	return strings.ToUpper(string(s[0])) + s[1:]
}

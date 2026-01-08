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

// Command represents a CLI command or subcommand
type Command struct {
	Name        string
	Description string
	Usage       string
	LongDesc    string
	Examples    []string
	Arguments   []Argument
	Flags       []Flag
	Subcommands []Subcommand
}

// Subcommand represents a subcommand entry in a parent command
type Subcommand struct {
	Name        string
	Description string
}

// Argument represents a command argument
type Argument struct {
	Name        string
	Description string
}

// Flag represents a command flag
type Flag struct {
	Short       string
	Long        string
	Type        string
	Description string
}

var (
	// Matches: "  -s, --long=TYPE  Description" or "  --long=TYPE  Description" or "  -s, --long  Description"
	// Also handles default values like --output="json" and repeatable flags like --env=ENV,...
	flagRE = regexp.MustCompile(`^\s{2,}(-([a-zA-Z]),\s+)?--([a-zA-Z0-9-]+)(=("[^"]+"|[A-Z0-9-=;]+(?:,\.\.\.)?|\.\.\.))?(\s{2,}(.+))?$`)
	// Matches subcommand lines: "  command subcommand [args] [flags]"
	subcommandRE = regexp.MustCompile(`^\s{2}(\S+(?:\s+\S+)?)\s+(\[.+\])?\s*$`)
	// Matches argument lines: "  [<arg>]  Description" or "  <arg>  Description"
	argumentRE = regexp.MustCompile(`^\s{2,}(\[?<([^>]+)>\]?)\s{2,}(.+)$`)
)

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintf(os.Stderr, "Usage: %s <cli-binary> <output-dir> [command-group...]\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s /path/to/bk ./pages/platform/cli/reference\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s /path/to/bk ./pages/platform/cli/reference build cluster\n", os.Args[0])
		os.Exit(1)
	}

	binary := os.Args[1]
	outputDir := os.Args[2]
	filterGroups := os.Args[3:]

	// Get root help to discover command groups
	rootHelp, err := getHelp(binary)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting root help: %v\n", err)
		os.Exit(1)
	}

	groups := discoverCommandGroups(rootHelp)

	// Filter groups if specified
	if len(filterGroups) > 0 {
		filtered := make(map[string]string)
		for _, g := range filterGroups {
			if desc, ok := groups[g]; ok {
				filtered[g] = desc
			} else {
				fmt.Fprintf(os.Stderr, "Warning: command group %q not found\n", g)
			}
		}
		groups = filtered
	}

	// Process each command group
	for groupName := range groups {
		fmt.Fprintf(os.Stderr, "Processing %s...\n", groupName)

		cmd, err := parseCommandGroup(binary, groupName)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error parsing %s: %v\n", groupName, err)
			continue
		}

		md := generateMarkdown(cmd)
		outputPath := filepath.Join(outputDir, groupName+".md")

		if err := os.WriteFile(outputPath, []byte(md), 0644); err != nil {
			fmt.Fprintf(os.Stderr, "Error writing %s: %v\n", outputPath, err)
			continue
		}

		fmt.Fprintf(os.Stderr, "  -> %s\n", outputPath)
	}
}

// getHelp runs the binary with --help and returns the output
func getHelp(binary string, args ...string) (string, error) {
	cmdArgs := append(args, "--help")
	cmd := exec.Command(binary, cmdArgs...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		// --help often returns non-zero, check if we got output
		if len(out) > 0 {
			return string(out), nil
		}
		return "", err
	}
	return string(out), nil
}

// discoverCommandGroups parses root --help to find command groups
func discoverCommandGroups(helpText string) map[string]string {
	groups := make(map[string]string)
	lines := strings.Split(helpText, "\n")

	inCommands := false
	for _, line := range lines {
		if strings.HasPrefix(line, "Commands:") {
			inCommands = true
			continue
		}
		if strings.HasPrefix(line, "Run ") {
			break
		}
		if !inCommands {
			continue
		}

		// Parse command lines like "  agent pause <agent-id> [flags]"
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		parts := strings.Fields(line)
		if len(parts) >= 1 {
			groupName := parts[0]
			// Skip standalone commands that aren't groups
			if !isCommandGroup(groupName) {
				continue
			}
			if _, exists := groups[groupName]; !exists {
				groups[groupName] = ""
			}
		}
	}

	return groups
}

// isCommandGroup returns true if the command should be documented
func isCommandGroup(name string) bool {
	// These are known commands from bk CLI (both groups and standalone)
	knownCommands := map[string]bool{
		"agent":     true,
		"api":       true,
		"artifacts": true,
		"build":     true,
		"cluster":   true,
		"configure": true,
		"init":      true,
		"job":       true,
		"package":   true,
		"pipeline":  true,
		"use":       true,
		"user":      true,
		"version":   true,
		"whoami":    true,
	}
	return knownCommands[name]
}

// parseCommandGroup parses a command group and all its subcommands
func parseCommandGroup(binary, groupName string) (*Command, error) {
	helpText, err := getHelp(binary, groupName)
	if err != nil {
		return nil, err
	}

	cmd := parseHelp(helpText, groupName)

	// Parse each subcommand for full details
	for i, sub := range cmd.Subcommands {
		subParts := strings.Fields(sub.Name)
		subName := subParts[len(subParts)-1] // Get the last part (e.g., "list" from "job list")

		subHelp, err := getHelp(binary, groupName, subName)
		if err != nil {
			fmt.Fprintf(os.Stderr, "  Warning: couldn't get help for %s %s: %v\n", groupName, subName, err)
			continue
		}

		subCmd := parseHelp(subHelp, sub.Name)
		cmd.Subcommands[i].Description = subCmd.Description
		if subCmd.LongDesc != "" {
			cmd.Subcommands[i].Description = subCmd.Description
		}
	}

	return cmd, nil
}

// parseHelp parses kong-style --help output
func parseHelp(helpText, cmdName string) *Command {
	cmd := &Command{Name: cmdName}
	lines := strings.Split(helpText, "\n")

	section := ""
	var descLines []string
	var currentFlagDesc strings.Builder
	var currentFlag *Flag

	flushFlag := func() {
		if currentFlag != nil {
			currentFlag.Description = strings.TrimSpace(currentFlagDesc.String())
			cmd.Flags = append(cmd.Flags, *currentFlag)
			currentFlag = nil
			currentFlagDesc.Reset()
		}
	}

	for i, line := range lines {
		trimmed := strings.TrimSpace(line)

		// Usage line
		if strings.HasPrefix(line, "Usage:") {
			cmd.Usage = strings.TrimPrefix(line, "Usage:")
			cmd.Usage = strings.TrimSpace(cmd.Usage)
			// Remove aliases like "(new)" from usage
			cmd.Usage = regexp.MustCompile(`\s*\([^)]+\)\s*`).ReplaceAllString(cmd.Usage, " ")
			cmd.Usage = strings.Join(strings.Fields(cmd.Usage), " ") // normalize spaces
			continue
		}

		// Section headers
		if trimmed == "Flags:" || trimmed == "Commands:" || trimmed == "Arguments:" || trimmed == "Examples:" {
			flushFlag()
			section = strings.TrimSuffix(trimmed, ":")
			continue
		}

		// Skip empty lines at start of sections
		if trimmed == "" && section == "" && i > 2 {
			// Collect description lines between Usage and first section
			if len(descLines) > 0 && descLines[len(descLines)-1] != "" {
				descLines = append(descLines, "")
			}
			continue
		}

		switch section {
		case "":
			// Description area (before any section)
			if i > 1 && trimmed != "" && !strings.HasPrefix(line, "Usage:") {
				descLines = append(descLines, trimmed)
			}

		case "Flags":
			if trimmed == "" {
				continue
			}
			// Check if this is a flag line or continuation
			if m := flagRE.FindStringSubmatch(line); m != nil {
				flushFlag()
				currentFlag = &Flag{
					Short: m[2],
					Long:  m[3],
					Type:  m[5],
				}
				if m[7] != "" {
					currentFlagDesc.WriteString(m[7])
				}
			} else if currentFlag != nil && len(line) > 0 && line[0] == ' ' {
				// Continuation of previous flag description (heavily indented lines)
				// Kong aligns continuation with the description column (lots of spaces)
				if currentFlagDesc.Len() > 0 {
					currentFlagDesc.WriteString(" ")
				}
				currentFlagDesc.WriteString(trimmed)
			}

		case "Commands":
			if trimmed == "" {
				continue
			}
			// Parse subcommand entries
			// Format: "  command subcommand [args] [flags]" followed by "    Description"
			// May include aliases like "build create (new) [flags]"
			// May include required flags like "pipeline migrate --file=STRING [flags]"
			if strings.HasPrefix(line, "  ") && !strings.HasPrefix(line, "    ") {
				// This is a command line
				parts := strings.Fields(trimmed)
				if len(parts) >= 1 {
					// Find where the args/flags start - skip aliases in parens and required flags
					cmdParts := []string{}
					for _, p := range parts {
						if strings.HasPrefix(p, "[") || strings.HasPrefix(p, "<") {
							break
						}
						// Skip aliases like "(new)"
						if strings.HasPrefix(p, "(") && strings.HasSuffix(p, ")") {
							continue
						}
						// Skip required flags like "--file=STRING"
						if strings.HasPrefix(p, "--") {
							break
						}
						cmdParts = append(cmdParts, p)
					}
					cmd.Subcommands = append(cmd.Subcommands, Subcommand{
						Name: strings.Join(cmdParts, " "),
					})
				}
			} else if strings.HasPrefix(line, "    ") && len(cmd.Subcommands) > 0 {
				// Description line for previous command
				idx := len(cmd.Subcommands) - 1
				cmd.Subcommands[idx].Description = trimmed
			}

		case "Arguments":
			if trimmed == "" {
				continue
			}
			if m := argumentRE.FindStringSubmatch(line); m != nil {
				cmd.Arguments = append(cmd.Arguments, Argument{
					Name:        m[1],
					Description: m[3],
				})
			} else if len(cmd.Arguments) > 0 && len(line) > 0 && line[0] == ' ' {
				// Continuation of previous argument description
				idx := len(cmd.Arguments) - 1
				cmd.Arguments[idx].Description += " " + trimmed
			}

		case "Examples":
			// Capture example lines - comments start with #, commands start with $
			// Commands can be multi-line (e.g., JSON data spanning multiple lines)
			if strings.HasPrefix(trimmed, "#") {
				cmd.Examples = append(cmd.Examples, trimmed)
			} else if strings.HasPrefix(trimmed, "$") {
				cmd.Examples = append(cmd.Examples, trimmed)
			} else if len(cmd.Examples) > 0 && trimmed != "" {
				// Continuation of previous command (multi-line example)
				lastIdx := len(cmd.Examples) - 1
				if !strings.HasPrefix(cmd.Examples[lastIdx], "#") {
					cmd.Examples[lastIdx] += "\n" + trimmed
				}
			}
		}
	}

	flushFlag()

	// Set description - filter out empty lines
	var nonEmptyDesc []string
	for _, d := range descLines {
		if d != "" {
			nonEmptyDesc = append(nonEmptyDesc, d)
		}
	}
	if len(nonEmptyDesc) > 0 {
		cmd.Description = nonEmptyDesc[0]
		if len(nonEmptyDesc) > 1 {
			// LongDesc is the full description (all lines after the first)
			cmd.LongDesc = strings.Join(nonEmptyDesc[1:], " ")
		}
	}

	return cmd
}

// generateMarkdown generates the markdown documentation for a command group
func generateMarkdown(cmd *Command) string {
	var b strings.Builder
	hasH2 := false

	// If no subcommands, document the command itself
	if len(cmd.Subcommands) == 0 {
		localFlags := filterLocalFlags(cmd.Flags)
		hasH2 = len(cmd.Arguments) > 0 || len(localFlags) > 0 || len(cmd.Examples) > 0

		// Header (with toc frontmatter if no h2 headings)
		b.WriteString(fileHeader(!hasH2))

		// Title and intro
		fmt.Fprintf(&b, "# Buildkite CLI %s command\n\n", cmd.Name)
		fmt.Fprintf(&b, "The `bk %s` command allows you to %s from the command line.\n\n",
			cmd.Name, getGroupDescription(cmd.Name))

		// Description
		if cmd.Description != "" {
			desc := cmd.Description
			if cmd.LongDesc != "" {
				desc += " " + cmd.LongDesc
			}
			fmt.Fprintf(&b, "%s\n\n", desc)
		}

		// Usage
		fmt.Fprintf(&b, "```bash\n%s\n```\n\n", cmd.Usage)

		// Arguments
		if len(cmd.Arguments) > 0 {
			b.WriteString("## Arguments\n\n")
			b.WriteString("| Argument | Description |\n")
			b.WriteString("| --- | --- |\n")
			for _, arg := range cmd.Arguments {
				fmt.Fprintf(&b, "| `%s` | %s |\n", arg.Name, arg.Description)
			}
			b.WriteString("\n")
		}

		// Flags
		if len(localFlags) > 0 {
			b.WriteString("## Flags\n\n")
			b.WriteString("| Flag | Description |\n")
			b.WriteString("| --- | --- |\n")
			for _, flag := range localFlags {
				flagStr := formatFlag(flag)
				fmt.Fprintf(&b, "| %s | %s |\n", flagStr, flag.Description)
			}
			b.WriteString("\n")
		}

		// Examples
		if len(cmd.Examples) > 0 {
			b.WriteString("## Examples\n\n")
			writeExamples(&b, cmd.Examples)
		}

		return b.String()
	}

	// Header (command groups always have h2 headings)
	b.WriteString(fileHeader(false))

	// Title and intro
	fmt.Fprintf(&b, "# Buildkite CLI %s command\n\n", cmd.Name)
	fmt.Fprintf(&b, "The `bk %s` command allows you to %s from the command line.\n\n",
		cmd.Name, getGroupDescription(cmd.Name))

	// Commands table for parent commands
	b.WriteString("## Commands\n\n")
	b.WriteString("| Command | Description |\n")
	b.WriteString("| --- | --- |\n")
	for _, sub := range cmd.Subcommands {
		fmt.Fprintf(&b, "| `bk %s` | %s |\n", sub.Name, sub.Description)
	}
	b.WriteString("\n")

	// Document each subcommand
	for _, sub := range cmd.Subcommands {
		subHelp, _ := getHelp(os.Args[1], strings.Fields(sub.Name)...)
		subCmd := parseHelp(subHelp, sub.Name)

		// Section title
		title := getSubcommandTitle(sub.Name)
		fmt.Fprintf(&b, "## %s\n\n", title)

		// Description
		if subCmd.Description != "" {
			fmt.Fprintf(&b, "%s\n\n", subCmd.Description)
		}

		// Usage (subCmd.Usage already includes "bk")
		fmt.Fprintf(&b, "```bash\n%s\n```\n\n", subCmd.Usage)

		// Arguments
		if len(subCmd.Arguments) > 0 {
			b.WriteString("### Arguments\n\n")
			b.WriteString("| Argument | Description |\n")
			b.WriteString("| --- | --- |\n")
			for _, arg := range subCmd.Arguments {
				fmt.Fprintf(&b, "| `%s` | %s |\n", arg.Name, arg.Description)
			}
			b.WriteString("\n")
		}

		// Flags (excluding global flags)
		localFlags := filterLocalFlags(subCmd.Flags)
		if len(localFlags) > 0 {
			b.WriteString("### Flags\n\n")
			b.WriteString("| Flag | Description |\n")
			b.WriteString("| --- | --- |\n")
			for _, flag := range localFlags {
				flagStr := formatFlag(flag)
				fmt.Fprintf(&b, "| %s | %s |\n", flagStr, flag.Description)
			}
			b.WriteString("\n")
		}

		// Examples
		if len(subCmd.Examples) > 0 {
			b.WriteString("### Examples\n\n")
			writeExamples(&b, subCmd.Examples)
		}
	}

	return b.String()
}

func fileHeader(disableToc bool) string {
	tocFrontmatter := ""
	if disableToc {
		tocFrontmatter = "---\ntoc: false\n---\n\n"
	}
	return fmt.Sprintf(`%s<!--

 _____           ______                _______    _ _
(____ \         |  ___ \       _      (_______)  | (_)_
 _   \ \ ___    | |   | | ___ | |_     _____   _ | |_| |_
| |   | / _ \   | |   | |/ _ \|  _)   |  ___) / || | |  _)
| |__/ / |_| |  | |   | | |_| | |__   | |____( (_| | | |__
|_____/ \___/   |_|   |_|\___/ \___)  |_______)____|_|\___)

This file is auto-generated by scripts/update-cli-help.sh.

To update this file:

1. Make changes to the CLI in https://github.com/buildkite/cli
2. Run ./scripts/update-cli-help.sh from the docs repo root

-->

`, tocFrontmatter)
}

func getGroupDescription(name string) string {
	descriptions := map[string]string{
		"agent":     "manage Buildkite agents",
		"api":       "interact with the Buildkite API",
		"artifacts": "manage build artifacts",
		"build":     "manage pipeline builds",
		"cluster":   "manage organization clusters",
		"configure": "configure your Buildkite CLI settings",
		"init":      "initialize a pipeline file with Buildkite Pipelines",
		"job":       "manage jobs within builds",
		"package":   "manage packages",
		"pipeline":  "manage pipelines",
		"use":       "choose which Buildkite organization to work with",
		"user":      "manage users in your organization",
		"version":   "display which version of the Buildkite CLI you're using",
		"whoami":    "display information about the current user's Buildkite organization and API token",
	}
	if desc, ok := descriptions[name]; ok {
		return desc
	}
	return "work with " + name
}

func getSubcommandTitle(name string) string {
	parts := strings.Fields(name)
	if len(parts) < 2 {
		return strings.Title(name)
	}

	action := parts[len(parts)-1]
	noun := parts[0]

	// Handle special cases for specific command combinations
	specialTitles := map[string]string{
		"configure add":    "Add a new organization",
		"artifacts download": "Download an artifact",
		"artifacts list":    "List artifacts",
	}
	if title, ok := specialTitles[name]; ok {
		return title
	}

	// Determine the correct article based on the noun
	article := "a"
	if startsWithVowelSound(noun) {
		article = "an"
	}

	// Generate readable titles
	switch action {
	case "list":
		return "List " + pluralize(noun)
	case "view":
		return "View " + article + " " + noun
	case "create":
		return "Create " + article + " " + noun
	case "cancel":
		return "Cancel " + article + " " + noun
	case "download":
		return "Download " + article + " " + noun
	case "rebuild":
		return "Rebuild " + article + " " + noun
	case "watch":
		return "Watch " + article + " " + noun
	case "pause":
		return "Pause " + article + " " + noun
	case "resume":
		return "Resume " + article + " " + noun
	case "stop":
		return "Stop " + pluralize(noun)
	case "retry":
		return "Retry " + article + " " + noun
	case "unblock":
		return "Unblock " + article + " " + noun
	case "validate":
		return "Validate " + article + " " + noun
	case "migrate":
		return "Migrate " + article + " " + noun
	}

	return strings.Title(action) + " " + noun
}

// startsWithVowelSound returns true if the word starts with a vowel sound
func startsWithVowelSound(word string) bool {
	if len(word) == 0 {
		return false
	}
	// Common cases - words starting with vowels (but not "user" which sounds like "yoozer")
	firstChar := strings.ToLower(string(word[0]))
	vowels := map[string]bool{"a": true, "e": true, "i": true, "o": true}
	// "u" is tricky - "user" starts with "y" sound, but "umbrella" starts with vowel sound
	// For CLI commands, "user" is the main "u" word, so we don't include "u"
	return vowels[firstChar]
}

// pluralize returns the plural form of a noun
func pluralize(noun string) string {
	if strings.HasSuffix(noun, "s") || strings.HasSuffix(noun, "x") ||
		strings.HasSuffix(noun, "ch") || strings.HasSuffix(noun, "sh") {
		return noun + "es"
	}
	if strings.HasSuffix(noun, "y") && len(noun) > 1 {
		// Check if preceded by a consonant
		prev := noun[len(noun)-2]
		if prev != 'a' && prev != 'e' && prev != 'i' && prev != 'o' && prev != 'u' {
			return noun[:len(noun)-1] + "ies"
		}
	}
	return noun + "s"
}

func filterLocalFlags(flags []Flag) []Flag {
	globalFlags := map[string]bool{
		"help":     true,
		"yes":      true,
		"no-input": true,
		"no-pager": true,
		"quiet":    true,
	}

	var local []Flag
	for _, f := range flags {
		if !globalFlags[f.Long] {
			local = append(local, f)
		}
	}

	// Sort flags: short flags first, then alphabetically
	sort.Slice(local, func(i, j int) bool {
		if local[i].Short != "" && local[j].Short == "" {
			return true
		}
		if local[i].Short == "" && local[j].Short != "" {
			return false
		}
		return local[i].Long < local[j].Long
	})

	return local
}

func formatFlag(f Flag) string {
	var parts []string
	if f.Short != "" {
		parts = append(parts, "`-"+f.Short+"`")
	}
	longFlag := "`--" + f.Long
	if f.Type != "" {
		// Keep default values (quoted) as-is, uppercase type placeholders
		if strings.HasPrefix(f.Type, "\"") {
			longFlag += "=" + f.Type
		} else {
			longFlag += "=" + strings.ToUpper(f.Type)
		}
	}
	longFlag += "`"
	parts = append(parts, longFlag)
	return strings.Join(parts, ", ")
}

func writeExamples(b *strings.Builder, examples []string) {
	var comment string
	for _, ex := range examples {
		if strings.HasPrefix(ex, "#") {
			// It's a comment - save it
			comment = strings.TrimPrefix(ex, "# ")
		} else if strings.HasPrefix(ex, "$") {
			// It's a command
			cmd := strings.TrimPrefix(ex, "$ ")
			if comment != "" {
				fmt.Fprintf(b, "%s:\n\n", comment)
				comment = ""
			}
			fmt.Fprintf(b, "```bash\n%s\n```\n\n", cmd)
		}
	}
}

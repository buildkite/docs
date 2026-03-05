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

func main() {
	if len(os.Args) < 3 {
		fmt.Fprintf(os.Stderr, "Usage: %s <cli-binary> <repo-root>\n", os.Args[0])
		os.Exit(1)
	}

	binary := os.Args[1]
	repoRoot := os.Args[2]

	commandsGoPath := filepath.Join(repoRoot, "scripts", "bk_cli2md", "commands.go")
	navYmlPath := filepath.Join(repoRoot, "data", "nav.yml")
	referenceMdPath := filepath.Join(repoRoot, "pages", "platform", "cli", "reference.md")

	// Discover commands from bk --help
	helpText, err := runHelp(binary)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error running %s --help: %v\n", binary, err)
		os.Exit(1)
	}
	discovered := discoverCommands(helpText)

	// Read current commands from commands.go
	current, err := readCommandsGo(commandsGoPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading %s: %v\n", commandsGoPath, err)
		os.Exit(1)
	}

	// Compute additions and removals
	discoveredSet := make(map[string]bool)
	for _, name := range discovered {
		discoveredSet[name] = true
	}

	var added, removed []string
	for _, name := range discovered {
		if _, ok := current[name]; !ok {
			added = append(added, name)
		}
	}
	for name := range current {
		if !discoveredSet[name] {
			// Verify the command is truly gone by checking if bk <name> --help fails
			if isValidCommand(binary, name) {
				fmt.Fprintf(os.Stderr, "  ~ %s (not in bk --help but still responds to bk %s --help, keeping)\n", name, name)
			} else {
				removed = append(removed, name)
			}
		}
	}
	sort.Strings(added)
	sort.Strings(removed)

	if len(added) == 0 && len(removed) == 0 {
		fmt.Fprintln(os.Stderr, "Command list is up to date.")
		return
	}

	// Log changes and get descriptions for new commands
	for _, name := range added {
		desc := getDescription(binary, name)
		current[name] = desc
		fmt.Fprintf(os.Stderr, "  + %s (%s)\n", name, desc)
	}
	for _, name := range removed {
		fmt.Fprintf(os.Stderr, "  - %s (removed)\n", name)
		fmt.Fprintf(os.Stderr, "    Note: manually remove pages/platform/cli/reference/%s.md if no longer needed\n", name)
		delete(current, name)
	}

	// Update all three files
	if err := writeCommandsGo(commandsGoPath, current); err != nil {
		fmt.Fprintf(os.Stderr, "Error writing %s: %v\n", commandsGoPath, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "  Updated %s\n", commandsGoPath)

	if err := updateNavYml(navYmlPath, current); err != nil {
		fmt.Fprintf(os.Stderr, "Error updating %s: %v\n", navYmlPath, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "  Updated %s\n", navYmlPath)

	if err := updateReferenceMd(referenceMdPath, current); err != nil {
		fmt.Fprintf(os.Stderr, "Error updating %s: %v\n", referenceMdPath, err)
		os.Exit(1)
	}
	fmt.Fprintf(os.Stderr, "  Updated %s\n", referenceMdPath)
}

// runHelp executes the binary with --help and returns the output.
func runHelp(binary string, args ...string) (string, error) {
	cmdArgs := append(args, "--help")
	cmd := exec.Command(binary, cmdArgs...)
	out, err := cmd.CombinedOutput()
	if err != nil && len(out) == 0 {
		return "", err
	}
	return string(out), nil
}

// discoverCommands parses bk --help output to find unique top-level command names.
// Only lowercase names are accepted, filtering out subcommand verbs and description
// words (like "Add", "Pause", "List") that may appear in expanded help output.
func discoverCommands(helpText string) []string {
	seen := make(map[string]bool)
	var names []string
	lines := strings.Split(helpText, "\n")

	inCommands := false
	for _, line := range lines {
		if strings.HasPrefix(line, "Commands:") {
			inCommands = true
			continue
		}
		if !inCommands {
			continue
		}
		if strings.HasPrefix(line, "Run ") || strings.HasPrefix(line, "Flags:") {
			break
		}

		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}

		parts := strings.Fields(trimmed)
		if len(parts) >= 1 {
			name := parts[0]
			if !isLowercase(name) {
				continue
			}
			if !seen[name] {
				seen[name] = true
				names = append(names, name)
			}
		}
	}

	sort.Strings(names)
	return names
}

// isLowercase returns true if the string contains only lowercase letters and hyphens.
func isLowercase(s string) bool {
	for _, r := range s {
		if r != '-' && (r < 'a' || r > 'z') {
			return false
		}
	}
	return len(s) > 0
}

// isValidCommand checks whether a command is a real top-level bk command
// by running bk <name> --help and checking for a valid Usage line.
func isValidCommand(binary, name string) bool {
	out, err := runHelp(binary, name)
	if err != nil && len(out) == 0 {
		return false
	}
	return strings.Contains(out, "Usage:")
}

// readCommandsGo parses commands.go to extract the current command->description map.
func readCommandsGo(path string) (map[string]string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	result := make(map[string]string)
	re := regexp.MustCompile(`\t"([^"]+)":\s+"([^"]+)"`)
	for _, match := range re.FindAllStringSubmatch(string(data), -1) {
		result[match[1]] = match[2]
	}
	return result, nil
}

// getDescription fetches the description for a command by running its --help
// and extracting the description text between the Usage line and first section header.
func getDescription(binary, name string) string {
	out, err := runHelp(binary, name)
	if err != nil || len(out) == 0 {
		return "work with " + name
	}

	lines := strings.Split(out, "\n")
	pastUsage := false
	for _, line := range lines {
		if strings.HasPrefix(line, "Usage:") {
			pastUsage = true
			continue
		}
		if !pastUsage {
			continue
		}
		trimmed := strings.TrimSpace(line)
		if trimmed == "" {
			continue
		}
		if trimmed == "Commands:" || trimmed == "Flags:" || trimmed == "Arguments:" || trimmed == "Examples:" {
			break
		}

		// Lowercase first letter and remove trailing period
		desc := strings.ToLower(string(trimmed[0])) + trimmed[1:]
		desc = strings.TrimSuffix(desc, ".")
		return desc
	}
	return "work with " + name
}

// writeCommandsGo regenerates commands.go with the given command map.
func writeCommandsGo(path string, commands map[string]string) error {
	var names []string
	for name := range commands {
		names = append(names, name)
	}
	sort.Strings(names)

	maxLen := 0
	for _, name := range names {
		if len(name) > maxLen {
			maxLen = len(name)
		}
	}

	var b strings.Builder
	b.WriteString(`package main

// commandDescriptions lists all bk CLI commands that should be documented,
// along with their human-readable descriptions used in the generated
// Markdown page introductions. When a new command is added to the CLI,
// add it here to include it in the generated documentation.
var commandDescriptions = map[string]string{
`)
	for _, name := range names {
		padding := strings.Repeat(" ", maxLen+1-len(name))
		fmt.Fprintf(&b, "\t\"%s\":%s\"%s\",\n", name, padding, commands[name])
	}
	b.WriteString("}\n")

	return os.WriteFile(path, []byte(b.String()), 0644)
}

// updateNavYml finds the "Command-line reference" children block in nav.yml
// and replaces the command entries (preserving the Overview entry).
func updateNavYml(path string, commands map[string]string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	lines := strings.Split(string(data), "\n")

	// Find the Overview path line for the CLI reference section.
	// This is the unique anchor: path: "platform/cli/reference" (no trailing slash).
	overviewEnd := -1
	for i, line := range lines {
		if strings.TrimSpace(line) == `path: "platform/cli/reference"` {
			overviewEnd = i + 1
			break
		}
	}
	if overviewEnd == -1 {
		return fmt.Errorf("could not find CLI reference Overview entry in nav.yml")
	}

	// Consume existing command entries (pairs of name + path lines)
	entriesEnd := overviewEnd
	for entriesEnd < len(lines) {
		trimmed := strings.TrimSpace(lines[entriesEnd])
		if !strings.HasPrefix(trimmed, `- name: "`) {
			break
		}
		if entriesEnd+1 >= len(lines) {
			break
		}
		nextTrimmed := strings.TrimSpace(lines[entriesEnd+1])
		if !strings.HasPrefix(nextTrimmed, `path: "platform/cli/reference/`) {
			break
		}
		entriesEnd += 2
	}

	// Build new entries
	var names []string
	for name := range commands {
		names = append(names, name)
	}
	sort.Strings(names)

	var newEntries []string
	for _, name := range names {
		newEntries = append(newEntries,
			fmt.Sprintf(`            - name: "%s"`, name),
			fmt.Sprintf(`              path: "platform/cli/reference/%s"`, name),
		)
	}

	var result []string
	result = append(result, lines[:overviewEnd]...)
	result = append(result, newEntries...)
	result = append(result, lines[entriesEnd:]...)

	return os.WriteFile(path, []byte(strings.Join(result, "\n")), 0644)
}

// updateReferenceMd finds the command list in reference.md and replaces it.
func updateReferenceMd(path string, commands map[string]string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		return err
	}

	lines := strings.Split(string(data), "\n")

	// Find the contiguous block of command list entries
	listStart := -1
	listEnd := -1
	for i, line := range lines {
		if strings.HasPrefix(line, "- [`") && strings.Contains(line, "](/docs/platform/cli/reference/") {
			if listStart == -1 {
				listStart = i
			}
			listEnd = i + 1
		}
	}
	if listStart == -1 {
		return fmt.Errorf("could not find command list in reference.md")
	}

	// Build new entries
	var names []string
	for name := range commands {
		names = append(names, name)
	}
	sort.Strings(names)

	var newEntries []string
	for _, name := range names {
		newEntries = append(newEntries, fmt.Sprintf("- [`%s`](/docs/platform/cli/reference/%s)", name, name))
	}

	var result []string
	result = append(result, lines[:listStart]...)
	result = append(result, newEntries...)
	result = append(result, lines[listEnd:]...)

	return os.WriteFile(path, []byte(strings.Join(result, "\n")), 0644)
}

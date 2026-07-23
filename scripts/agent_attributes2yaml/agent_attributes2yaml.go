package main

import (
	"bufio"
	"fmt"
	"log/slog"
	"os"
	"os/user"
	"regexp"
	"strings"
)

var (
	optionLineRE    = regexp.MustCompile(`^  --`)
	envAnnotationRE = regexp.MustCompile(`\[((?:\$[A-Z][A-Z0-9_]*)(?:,\s*\$[A-Z][A-Z0-9_]*)*)\]\s*$`)
	envNameRE       = regexp.MustCompile(`\$[A-Z][A-Z0-9_]*`)
	defaultValRE    = regexp.MustCompile(`\(default:([^)]*)\)`)
	stripOptionRE   = regexp.MustCompile(`^[a-zA-Z0-9-]+( value)?[ ]*`)
	stripDefaultRE  = regexp.MustCompile(`[ ]*\(default:[^)]*\)`)
	stripEnvVarRE   = regexp.MustCompile(`[ ]*\[\$[^\]]*\][ ]*$`)
)

var (
	requiredOptions = map[string]bool{"token": true, "build-path": true}
	excludedOptions = map[string]bool{"config": true}
)

func main() {
	u, err := user.Current()
	if err != nil {
		slog.Error("Couldn't get current user", "error", err)
		os.Exit(1)
	}

	fmt.Println("attributes:")

	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		line := scanner.Text()
		if !optionLineRE.MatchString(line) {
			continue
		}

		rest := line[4:] // strip leading "  --"

		fields := strings.Fields(rest)
		if len(fields) == 0 {
			continue
		}
		name := fields[0]

		if excludedOptions[name] {
			continue
		}

		// Extract env var from the trailing [...] annotation (which may contain
		// multiple comma-separated vars), not bracketed text in the description.
		envVar := extractEnvVars(line)

		// Extract default value from (default:...)
		defaultVal := ""
		if m := defaultValRE.FindStringSubmatch(line); m != nil {
			defaultVal = strings.TrimSpace(m[1])
			defaultVal = strings.ReplaceAll(defaultVal, u.HomeDir, "~")
		}

		// Extract description by stripping option name/value, default, and env var
		desc := stripOptionRE.ReplaceAllString(rest, "")
		desc = stripDefaultRE.ReplaceAllString(desc, "")
		desc = stripEnvVarRE.ReplaceAllString(desc, "")
		desc = strings.TrimSpace(desc)

		fmt.Printf("  - name: %q\n", name)
		fmt.Printf("    env_var: |\n")
		fmt.Printf("      %s\n", envVar)
		fmt.Printf("    default_value: |\n")
		if defaultVal == "" {
			fmt.Println()
		} else {
			fmt.Printf("      %s\n", defaultVal)
		}
		fmt.Printf("    required: %v\n", requiredOptions[name])
		fmt.Printf("    desc: |\n")
		fmt.Printf("      %s\n", desc)
	}
	if err := scanner.Err(); err != nil {
		slog.Error("Failed scanning lines from stdin", "error", err)
		os.Exit(1)
	}
}

func extractEnvVars(line string) string {
	m := envAnnotationRE.FindStringSubmatch(line)
	if m == nil {
		return ""
	}

	return strings.Join(envNameRE.FindAllString(m[1], -1), "\n      ")
}

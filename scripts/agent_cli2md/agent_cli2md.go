package main

import (
	"bufio"
	"fmt"
	"html"
	"log/slog"
	"os"
	"os/user"
	"regexp"
	"strings"
)

type state int

const (
	statePlain state = iota
	stateCode
	stateTable
)

var (
	headingRE      = regexp.MustCompile(`^(\w*):$`) // Headings end in `:`
	codeBlockRE    = regexp.MustCompile(`^\s{4}`)
	flagRE         = regexp.MustCompile(`\s{2}(-{2}[a-z0-9\- ]*)([A-Z].*)$`)
	bkEnvVarRE     = regexp.MustCompile(`\$BUILDKITE[A-Z0-9_]*`)
	bracketedVarRE = regexp.MustCompile(`\s\[\$BUILDKITE[A-Z0-9_]*\]`)
)

func main() {
	user, err := user.Current()
	if err != nil {
		slog.Error("Couldn't get current user", "error", err)
		os.Exit(1)
	}

	state := statePlain

	buf := bufio.NewScanner(os.Stdin)
	for lineNum := 0; buf.Scan(); lineNum++ {
		line := buf.Text()

		// Replace all prime symbols with backticks. We use prime symbols instead of backticks in CLI
		// helptext because the cli framework we use, urfave/cli, has special handling for backticks.
		//
		// See: https://github.com/buildkite/agent/blob/main/clicommand/prime-signs.md
		line = strings.Map(func(r rune) rune {
			if r == '′' {
				return '`'
			}
			return r
		}, line)

		// Some agent help texts dynamically replace $HOME with the current user's home directory.
		// We need to replace it back for the docs
		line = strings.ReplaceAll(line, user.HomeDir, "$HOME")

		// Initial usage command
		if lineNum == 2 {
			fmt.Printf("`%s`\n", strings.TrimSpace(line))
			continue
		}

		// Headings end in `:`
		if m := headingRE.FindStringSubmatch(line); m != nil {
			fmt.Printf("### %s\n", m[1])
			state = statePlain
			continue
		}

		// code blocks
		if codeBlockRE.MatchString(line) {
			if state != stateCode {
				fmt.Println("```shell")
			}
			fmt.Println(codeBlockRE.ReplaceAllString(line, ""))
			state = stateCode
			continue
		}

		// Lists of parameters
		//  --config value             Path to a configuration file [$BUILDKITE_AGENT_CONFIG]
		if m := flagRE.FindStringSubmatch(line); m != nil {
			if state != stateTable {
				fmt.Println("<!-- vale off -->\n\n" + `<table class="Docs__attribute__table">`)
			}

			commandAndValue := strings.Fields(m[1])
			command := commandAndValue[0][2:]
			value := ""
			if len(commandAndValue) > 1 {
				value = commandAndValue[1]
			}
			desc := m[2]

			// Extract $BUILDKITE_* env and remove from desc
			envVar := bkEnvVarRE.FindString(desc)
			desc = bracketedVarRE.ReplaceAllString(desc, "")

			// Wrap https://agent.buildkite.com/v3 in code
			desc = strings.ReplaceAll(desc, "https://agent.buildkite.com/v3", "<code>https://agent.buildkite.com/v3</code>")

			fmt.Printf(`<tr id="%s">`, command)
			fmt.Printf(`<th><code>--%[1]s %[2]s</code> <a class="Docs__attribute__link" href="#%[1]s">#</a></th>`, command, value)
			fmt.Printf("<td><p>%s", desc)
			if envVar != "" {
				fmt.Printf("<br /><strong>Environment variable</strong>: <code>%s</code>", envVar)
			}
			fmt.Println("</p></td></tr>")
			state = stateTable
			continue
		}

		switch state {
		case stateTable:
			// first line after a table
			fmt.Println("</table>\n\n<!-- vale on -->")
			fmt.Println(line)
			state = statePlain

		case stateCode:
			// first line after a code block
			fmt.Println("```")
			fmt.Println(line)
			state = statePlain

		case statePlain:
			// just escape the line
			fmt.Println(html.EscapeString(strings.TrimSpace(line)))

		default:
			slog.Error("Unknown state", "state", state, "line_num", lineNum, "line", line)
		}
	}
	if err := buf.Err(); err != nil {
		slog.Error("Failed scanning lines from stdin", "error", err)
		os.Exit(1)
	}

	// handle when the last line was in a code block or table
	switch state {
	case stateTable:
		fmt.Println("</table>\n\n<!-- vale on -->")

	case stateCode:
		fmt.Println("```")
	}
}

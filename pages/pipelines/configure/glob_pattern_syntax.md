# Glob pattern syntax

A glob pattern is "what a file name looks like". Glob patterns are a compact way
of referring to multiple files at once, by
writing a pattern that is used to find all file paths that match that pattern.

This syntax is used for glob patterns supported in pipelines for artifact
uploads (using either `artifact_paths` in a pipeline or
`buildkite-agent artifact upload`), and `if_changed` conditions on pipeline
steps.

> 📘 Full path matching
> Glob patterns must match whole path strings, not just substrings. However
> they are usually evaluated relative to the current directory.

## Syntax elements

Characters match themselves only, with the following syntax elements having
special meaning.

Element | Meaning
--- | ---
`\` | Used to _escape_ the next character in the pattern, preventing it from being treated as special syntax. The escaped character matches itself exactly. For example, `\*` matches `*` (_not_ zero or more arbitrary characters). Note that on Windows, `\` and `/` have swapped meanings.
`/` | The path separator. Separates segments of each path. Within a path, it matches itself only. Note that on Windows, `\` and `/` have swapped meanings.
`?` | Matches exactly one arbitrary character, except for  the path separator `/`.
`*` | Matches zero or more arbitrary characters, except for the path separator `/`.
`**` | Matches zero or more arbitrary characters, including the path separator `/`. Since it can be used to mean zero or more path components, `/**/` also matches `/`.
`{,}` | `{a,b,c}` matches `a` or `b` or `c`. A component can be empty, e.g. `{,a,b}` matches either nothing or `a` or `b`. Multiple path segments, `*`, `**`, etc are all allowed within `{}`. To specify a path containing `,` within `{}`, escape it (`\,`).
`[ ]` | `[abc]` matches a single character (`a` or `b` or `c`). `[]` is a shorter way to write a match for a single character than `{,}`. Note that ranges are currently not supported.
`[^ ]` | `[^abc]` matches a single character _other than_ the listed characters. Note that ranges are currently not supported.
`~` | Prior to matching, `~` is expanded to the current user's home directory.

> 📘 On Windows
> `\` is the path separator on Windows, and `/` is the escape character when the agent performing the action is running on Windows, as unlike other platforms, `\` is the standard Windows path separator.

Also note the following about character classes.

> 📘 Character classes
> Character classes (`[abc]`) and negated character classes (`[^abc]`) currently do _not_ support ranges, and `-` is treated literally. For example, `[c-g]` only matches one of `c`, `g`, or `-`.

## Examples

Pattern | Explanation
--- | ---
`foo?.txt` | Matches files in the current directory whose names start with `foo`, followed by any one arbitrary character, and ending with `.txt`
`foo*.txt` | Matches files in the current directory whose names start with `foo`, followed by any number of other characters, and ending with `.txt`
`foo\?.txt` | Matches the file in the current directory named `foo?.txt`
`log????.out` | Matches files in the current directory whose names start with `log`, followed by exactly four arbitrary characters, and ending with `.out`.
`log[^789]???.out` | Like `log????.out`, but the first character after `log` must not be `7`, `8`, or `9`.
`log???[16].out` | Like `log????.out`, but the last character before `.out` must be `1` or `6`.
`foo/*` | Matches all files within the `foo` directory only
`foo/**` | Matches all files within the `foo` directory, or any subdirectory of `foo`
`*.go` | Matches all Go files within the current directory only
`**.go` | Matches all Go files within the current directory or any subdirectory
`**/*.go` | Equivalent to `**.go`
`foo/**.go` | Matches all Go files within the `foo` directory or any subdirectory
`foo/**/*.go` | Equivalent to `foo/**.go`
`foo/**/bar/*` | Matches all files in every subdirectory named `bar` anywhere among the subdirectories of `foo` (including e.g. `foo/bar` and `foo/tmp/logs/bar`)
`{foo,bar}.go` | Matches the files `foo.go` and `bar.go` (in the current directory)
`foo{,bar}.go` | Matches the files `foo.go` and `foobar.go` (in the current directory)
`go.{mod,sum}` | Matches the files `go.mod` and `go.sum` (in the current directory)
`**/go.{mod,sum}` | Matches `go.mod` and `go.sum` within the current directory or any subdirectory
`{foo,bar}/**.go` | Matches all Go files within the `foo` directory, the `bar` directory, or any of their subdirectories
`{foo/**.go,fixtures/**}` | Matches all Go files within the `foo` directory and its subdirectories, and all files within the `fixtures` directory and its subdirectories
`side[AB]` | Matches the files `sideA` and `sideB` (in the current directory)
`scale_[ABCDEFG]` | Matches the files `scale_A` through `scale_G` (in the current directory)
`~/.bash_profile` | Matches the `.bash_profile` file in the current user's home directory

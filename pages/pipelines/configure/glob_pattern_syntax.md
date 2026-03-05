# Glob pattern syntax

A glob pattern is a representation of a file name and optionally its path, and is a compact way of specifying multiple files with a single pattern. You can use a glob pattern to find all files in paths that match that pattern.

This syntax is used for glob patterns supported in pipelines for artifact uploads (using either [`artifact_paths`](/docs/pipelines/configure/step-types/command-step#command-step-attributes) in a pipeline or [`buildkite-agent artifact upload`](/docs/agent/cli/reference/pipeline)), and `if_changed` conditions on [command](/docs/pipelines/configure/step-types/command-step#agent-applied-attributes), [trigger](/docs/pipelines/configure/step-types/trigger-step#agent-applied-attributes) or [group](/docs/pipelines/configure/step-types/group-step#agent-applied-attributes) pipeline steps.

> 📘 Full path matching
> Glob patterns must match whole path strings, and cannot be used to represent substrings. However, glob patterns are evaluated relative to the current directory.

## Syntax elements

Characters match themselves only, with the following syntax elements having special meaning.

<table>
  <thead>
    <tr>
      <th style="width:10%">Syntax element</th>
      <th style="width:90%">Meaning</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "syntax_element": "\\",
        "meaning": "Used to <em>escape</em> the next character in the pattern, preventing it from being treated as special syntax. An escaped character matches itself exactly. For example, <code>\\*</code> matches <code>*</code> (<em>not</em> zero or more arbitrary characters). Note that on Windows, <code>\\</code> and <code>/</code> have swapped meanings."
      },
      {
        "syntax_element": "/",
        "meaning": "The path separator. Separates segments of each path. Note that on Windows, <code>\\</code> and <code>/</code> have swapped meanings."
      },
      {
        "syntax_element": "?",
        "meaning": "Matches exactly one arbitrary character, except for  the path separator <code>/</code>."
      },
      {
        "syntax_element": "*",
        "meaning": "Matches zero or more arbitrary characters, except for the path separator <code>/</code>. Note that YAML strings starting with <code>*</code> must typically be quoted."
      },
      {
        "syntax_element": "**",
        "meaning": "Matches zero or more arbitrary characters, including the path separator <code>/</code>. Since <code>**</code> can be used to mean zero or more path components, <code>/**/</code> also matches <code>/</code>. Note that YAML strings starting with <code>*</code> must typically be quoted."
      },
      {
        "syntax_element": "{,}",
        "meaning": "<code>{a,b,cd}</code> matches <code>a</code> or <code>b</code> or <code>cd</code>. A component can be empty, e.g. <code>{,a,b}</code> matches either nothing or <code>a</code> or <code>b</code>. Multiple path segments, <code>*</code>, <code>**</code>, etc are all allowed within <code>{}</code>. To specify a path containing <code>,</code> within <code>{}</code>, escape it (that is, use <code>\\,</code>). Note that patterns within braces remain whitespace-sensitive: <code>{a, b}</code> matches <code>a</code> and <code>&nbsp;b</code> (a space followed by b), not <code>b</code>."
      },
      {
        "syntax_element": "[ ]",
        "meaning": "<code>[abc]</code> matches single characters only (<code>a</code> or <code>b</code> or <code>c</code>). <code>[]</code> is a shorter way to write a match for a single character than <code>{,}</code>. Note that ranges are currently not supported."
      },
      {
        "syntax_element": "[^ ]",
        "meaning": "<code>[^abc]</code> matches a single character <em>other than</em> the listed characters. Note that ranges are currently not supported."
      },
      {
        "syntax_element": "~",
        "meaning": "Prior to matching, <code>~</code> is expanded to the current user's home directory. Note that YAML typically interprets a single <code>~</code> as <code>null</code>."
      }
    ].select { |field| field[:syntax_element] }.each do |field| %>
      <tr>
        <td>
          <p><code><%= field[:syntax_element] %></code></p>
        </td>
        <td>
          <p><%= field[:meaning] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

### On Windows

The path separator on Windows is `\`, and therefore, `/` is the escape character when the agent performing the action is running on Windows. On other operating system platforms, `/` is the standard path separator and `\` is the standard escape character for the agent.

### Character classes

Character classes (`[abc]`) and negated character classes (`[^abc]`) currently do _not_ support ranges, and `-` is treated literally. For example, `[c-g]` only matches one of `c`, `g`, or `-`.

## Examples

<table>
  <thead>
    <tr>
      <th style="width:25%">Pattern</th>
      <th style="width:75%">Explanation</th>
    </tr>
  </thead>
  <tbody>
    <% [
      {
        "pattern": "foo?.txt",
        "explanation": "Matches files in the current directory whose names start with <code>foo</code>, followed by any one arbitrary character, and ending with <code>.txt</code>."
      },
      {
        "pattern": "foo*.txt",
        "explanation": "Matches files in the current directory whose names start with <code>foo</code>, followed by any number of other characters, and ending with <code>.txt</code>."
      },
      {
        "pattern": "foo\\?.txt",
        "explanation": "Matches the file in the current directory named <code>foo?.txt</code>."
      },
      {
        "pattern": "log????.out",
        "explanation": "Matches files in the current directory whose names start with <code>log</code>, followed by exactly four arbitrary characters, and ending with <code>.out</code>."
      },
      {
        "pattern": "log[^789]???.out",
        "explanation": "Like <code>log????.out</code>, but the first character after <code>log</code> must not be <code>7</code>, <code>8</code>, or <code>9</code>."
      },
      {
        "pattern": "log???[16].out",
        "explanation": "Like <code>log????.out</code>, but the last character before <code>.out</code> must be <code>1</code> or <code>6</code>."
      },
      {
        "pattern": "foo/*",
        "explanation": "Matches all files within the <code>foo</code> directory only."
      },
      {
        "pattern": "foo/**",
        "explanation": "Matches all files within the <code>foo</code> directory, as well as any subdirectory of <code>foo</code>."
      },
      {
        "pattern": "*.go",
        "explanation": "Matches all Go files within the current directory only."
      },
      {
        "pattern": "**.go",
        "explanation": "Matches all Go files within the current directory as well as any of its subdirectories."
      },
      {
        "pattern": "**/*.go",
        "explanation": "Equivalent to <code>**.go</code>."
      },
      {
        "pattern": "foo/**.go",
        "explanation": "Matches all Go files within the <code>foo</code> directory as well as any of its subdirectories."
      },
      {
        "pattern": "foo/**/*.go",
        "explanation": "Equivalent to <code>foo/**.go</code>."
      },
      {
        "pattern": "foo/**/bar/*",
        "explanation": "Matches all files in every subdirectory named <code>bar</code> anywhere within the <code>foo</code> directory (including, for example, both <code>foo/bar</code> and <code>foo/tmp/logs/bar</code>)."
      },
      {
        "pattern": "{foo,bar}.go",
        "explanation": "Matches the files <code>foo.go</code> and <code>bar.go</code> in the current directory."
      },
      {
        "pattern": "foo{,bar}.go",
        "explanation": "Matches the files <code>foo.go</code> and <code>foobar.go</code> in the current directory."
      },
      {
        "pattern": "go.{mod,sum}",
        "explanation": "Matches the files <code>go.mod</code> and <code>go.sum</code> in the current directory."
      },
      {
        "pattern": "**/go.{mod,sum}",
        "explanation": "Matches <code>go.mod</code> and <code>go.sum</code> within the current directory as well as any of its subdirectories."
      },
      {
        "pattern": "{foo,bar}/**.go",
        "explanation": "Matches all Go files within the <code>foo</code> directory, the <code>bar</code> directory, as well as any of their subdirectories."
      },
      {
        "pattern": "{foo/**.go,fixtures/**}",
        "explanation": "Matches all Go files within the <code>foo</code> directory as well as its subdirectories, and all files within the <code>fixtures</code> directory as well as its subdirectories."
      },
      {
        "pattern": "side[AB]",
        "explanation": "Matches the files <code>sideA</code> and <code>sideB</code> in the current directory."
      },
      {
        "pattern": "scale_[ABCDEFG]",
        "explanation": "Matches the files <code>scale_A</code> through <code>scale_G</code> in the current directory."
      },
      {
        "pattern": "~/.bash_profile",
        "explanation": "Matches the <code>.bash_profile</code> file in the current user's home directory."
      }
    ].select { |field| field[:pattern] }.each do |field| %>
      <tr>
        <td>
          <p><code><%= field[:pattern] %></code></p>
        </td>
        <td>
          <p><%= field[:explanation] %></p>
        </td>
      </tr>
    <% end %>
  </tbody>
</table>

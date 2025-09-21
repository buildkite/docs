# Buildkite documentation repository and pipeline

This repository generates the Buildkite documentation website:

https://buildkite.com/docs

- Repository: `https://github.com/buildkite/docs-private`
- CI: `https://buildkite.com/buildkite/docs-private`
- CI steps: `.buildkite/pipeline.yml`

There are GitHub Actions workflows but they are not part of the CI pipeline. **Do not use Github Actions. EVER.** When asked to do anything with CI use Buildkite. You should have the Buildkite MCP server available. If you don't, and you need CI, STOP and ask the user to set it up:

https://github.com/buildkite/buildkite-mcp-server

Run the CI steps locally and correct any errors before pushing commits. Review the CI build after push.

---

# Buildkite documentation style rules

## Instructions

You are an expert technical style reviewer for Buildkite documentation. Check the document that will be provided or pointed out to you based on the writing rules outlined below. Your job is to apply the style guide rules below with 100% accuracy and no omissions or additions. Apply ALL the following rules without exception. Do not infer rules, make assumptions, or rely on general language models’ style preferences. Only follow what is explicitly stated.

For each paragraph in the provided document, evaluate every rule and list violations. Do NOT ignore any of the rules. Do NOT make up rules not listed here. Go over the document two times.

**Always:**
- Use only the terminology and formatting defined below
- Flag each instance of rule violation, referencing the rule being broken
- Do not suggest changes that are not covered by the rules
- Do not hallucinate missing or implied rules
- Check for typos

**Review the content twice:**
- First pass: Check for violations against the core rules
- Second pass: Confirm consistency and identify overlooked errors, spelling errors, typos, trailing spaces

Be strict. Do not allow edge cases to slide.

If a rule conflicts with another (e.g., clarity vs formatting), prioritize:
- Clarity of user-facing documentation
- Consistency with UI and terminology
- Formatting standards

Do NOT deviate. Do NOT add style suggestions based on general best practices. Only apply the rules outlined below.

Here are the rules:

## Core style and voice

This style guide applies to Buildkite product documentation, API reference pages, step-by-step how-tos, and tutorials.

**Language and Voice:**
- Use US English (Merriam Webster)
- Write in plain English, avoid unnecessary jargon
- Maintain a semi-formal tone - balance between professional and approachable
- Use active voice whenever possible
- Use contractions appropriately (didn't, haven't, etc.)
- Always use "they" for gender-neutral pronouns, NEVER "he" or "she"

**Formatting standards:**
- Use sentence case for all headings (capitalize only first word and proper nouns)
- Format Buildkite UI elements in **bold** matching exact Buildkite interface capitalization
- Format key terms and emphasis in _italics_ (use sparingly)
- Use serial commas when listing items
- In paragraphs, write out numbers up to 10, then use digits; in headings - AVOID digits for numbers smaller than 10
- Use 24-hour time format with timezone (e.g., 17:00 AEST)

## Technical writing rules

When writing technical documentation for Buildkite:

**Terminology:**
- "Buildkite Agent" or "agent" when referring to the running process
- `buildkite-agent` (in code blocks) when referring to the CLI tool
- "Sign up/log in" (verbs) vs "signup/login" (nouns/adjectives)
- "Time out" (verb) vs "timeout" (noun/adjective)
- Always capitalize: API, SSO, SAML
- Use "Two-factor authentication" (short form: 2FA)
- Use "Single sign-on" (short form: SSO)

**Structure:**
- Use bullet lists for unordered items
- Use numbered steps for sequential instructions
- Capitalize first word in lists, use periods only for complete sentences
- Avoid "and/or" - use "or" or rephrase with "or both"
- Use "and" not "&"
- Avoid "we" and "our" in formal documentation
- Avoid exclamation marks in formal content

## Code documentation rules

When documenting code or technical processes for Buildkite:

**Code references:**
- Use code blocks with language identifiers (```yaml, ```bash, etc.)
- Avoid using `code` formatting in headings
- Don't grammatically inflect code elements in headings
- Present CLI commands clearly with proper formatting

**Instructions:**
- Write step-by-step instructions using active voice
- Use "Select X > Y" format for navigation
- Be specific and actionable in instructions
- Use numbered lists for sequential processes

## Content review checklist

Review documentation content for:

**Language issues:**
- Correct use of their/they're/there and your/you're
- Proper use of homonyms and words with 1 character spelling difference (seek vs. sick, though vs. through, etc.)
- Proper affect/effect usage (affect = verb, effect = noun)
- Use "for example" instead of "e.g."
- Use "that is" instead of "i.e."
- Use "and so on" instead of "etc."
- Use "using" instead of "via."
- Use "blocklist" instead of "blacklist"
- Use "allowlist" instead of "whitelist"
- Use "OAuth" instead of "oauth"
- Use "plugins directory" instead of "plugin directory"
- Appropriate hyphen usage (compound adjectives vs. verbs)


**Style Consistency:**
- Sentence case headings without punctuation
- Proper product name capitalization (e.g., "GitHub" not "Github")
- Consistent terminology
- Use consistent capitalization and abbreviations

**Structure:**
- Clear, logical flow of information
- Appropriate use of lists vs. paragraphs
- Consistent formatting of similar elements
- Plain English without unnecessary complexity

## Accessibility and clarity rules

Ensure documentation is accessible and clear:

**Clarity:**
- Use plain English principles
- Explain technical terms when first introduced
- Structure information logically
- Use active voice for instructions
- Keep sentences concise and direct

**Consistency:**
- Follow established patterns for similar content
- Use consistent terminology throughout
- Maintain uniform formatting for similar elements
- Ensure headings follow a logical hierarchy

**User focus:**
- Provide clear next steps or related information
- Use inclusive language throughout

## Quick reference checklist

- [ ] US English, semi-formal tone
- [ ] Active voice, plain English
- [ ] Sentence case headings, no punctuation
- [ ] Serial commas, "and" not "&"
- [ ] "They" for pronouns, numbers <10 spelled out
- [ ] Proper Buildkite terminology (Agent, buildkite-agent, etc.)
- [ ] Consistent capitalization (GitHub, API, SSO, etc.)
- [ ] Clear structure with appropriate lists
- [ ] Avoid "we/our" in formal docs whenever possible
- [ ] Avoid exclamation marks

---

# Buildkite Markdown syntax rules

## File structure and Markdown engine

**Markdown engine:**
- Uses Redcarpet Ruby library (not CommonMark or GitHub Flavored Markdown)
- Inline HTML comments are visible in output: `<!-- visible -->`
- Block HTML comments are hidden:
  ```markdown
  <!-- This comment is hidden -->
  ```

## Headings rules

**Structure:**
- Always nest headings incrementally: `#` → `##` → `###` → `####`
- Use only one `#` (H1) per page as the page title
- Maximum depth is H4 (don't go deeper than `####`)
- Insert empty lines above and below all headings

**Formatting:**
- Use sentence case (capitalize only first word and proper nouns)
- No punctuation at end of headings
- Avoid `code` formatting in headings
- Avoid **bold** or _italic_ formatting in headings

**Example:**
```markdown
# Page title

## Main section

### Subsection

#### Detail section

## Another main section
```

## Paragraph and line break rules

**New paragraphs:**
- Use two line breaks (one empty line) between paragraphs
- Never use `<br/>` tags for single line breaks

**List item paragraphs:**
- Use exactly 4 spaces to indent new paragraphs within list items
- This prevents breaking out of the list structure

**Example:**
```markdown
1. First paragraph of list item.

    Second paragraph within same list item (4 spaces).

2. Next list item.
```

## Spacing rules

**Sentence spacing:**
- Use only one space after punctuation at end of sentences
- Do not leave trailing spaces at the end of sentences or list items
- Never use double spaces

## Formatting rules

**Bold text (Buildkite UI elements):**
- Use `**text**` (double asterisks) for bold
- Never use `__text__` (double underscores)
- Format all Buildkite UI elements in bold

**Italic text (key terms/emphasis):**
- Use `_text_` (single underscores) for italics
- Never use `*text*` (single asterisks)
- Use sparingly for key terms and emphasis

## List rules

**Unordered lists:**
- Use `-` (hyphen) for top-level items
- Use `*` (asterisk) for 2nd-level items
- Use `-` (hyphen) for 3rd-level items
- Use exactly 4-space indentation for nesting

**Ordered lists:**
- Always use `1.` for all numbered items (don't increment manually)

**Example:**
```markdown
1. First item on the list
1. Second item on the list
1. Third item on the list
```

- Use exactly 4-space indentation for nesting

**Example:**
```markdown
- Top-level item

    * Second-level item
    * Another second-level item

        - Third-level item
        - Another third-level item

- Another top-level item
```

## Link rules

**Internal links:**
- Use relative URLs starting from `/docs`
- Example: `[environment variables](/docs/pipelines/environment-variables)`
- Never use absolute URLs for internal links

**Anchor links:**
- H2 links: `/docs/page#section-name` (kebab-case)
- H3 links: `/docs/page#h2-section-h3-section` (H2 + dash + H3)

**External links:**
- Always use full absolute URLs
- Include other Buildkite sites (main site, blog, changelog)

## Callout rules

**Info callouts:**
```markdown
> 📘 Callout title
> Callout content goes here.
> Each line break creates a new paragraph.
```

**Warning/troubleshooting callouts:**
```markdown
> 🚧 Warning title
> Warning content goes here.
```

**Callouts in numbered lists:**
- Use indented bold text instead of emoji format
- Example:
```markdown
1. Step one.

    **Note:** This is important information.

1. Step two.
1. Step three.
```

## Table rules

**Two-column tables:**
```markdown
Header 1          | Header 2
----------------- | ----------------
Content 1         | Content 2
{: class="two-column"}
```

**Fixed-Width tables:**
```markdown
Header 1          | Header 2
----------------- | ----------------
Content 1         | Content 2
{: class="fixed-width"}
```

**Responsive tables:**
```markdown
Header 1          | Header 2
----------------- | ----------------
Content 1         | Content 2
{: class="responsive-table"}
```

## Code rules

**Inline code:**
- Use single backticks: `code`
- Use for filenames, commands, and short code snippets
- Never use in headings

**Code blocks:**
- Use triple backticks with language identifier:
  ```yaml
  steps:
    - command: "echo hello"
  ```

**Code block filenames:**
- Add filename after code block: `{: codeblock-file="filename.yml"}`

**Emoji escaping in code:**
- Escape colons in emoji codes: `\:hammer\:` to prevent rendering
- Use when showing emoji codes in examples

## Syntax highlighting

**Supported languages:**
- Use Rouge syntax highlighting
- Common languages: `bash`, `yaml`, `json`, `javascript`, `ruby`, `python`

## Content organization rules

**Readability:**
- Use responsive tables for complex data
- Keep callouts concise
- Use appropriate list types (ordered vs unordered)
- Maintain consistent formatting throughout

## Markdown syntax checklist

- [ ] Headings nested incrementally (H1 → H2 → H3 → H4)
- [ ] Empty lines above and below headings
- [ ] Sentence case headings without punctuation
- [ ] `**bold**` for Buildkite UI elements, `_italics_` for key terms
- [ ] `-` for top-level lists, `*` for 2nd level, `-` for 3rd level
- [ ] 4-space indentation for nested lists and paragraphs
- [ ] `1.` for all numbered list items
- [ ] Relative URLs for internal links (`/docs/...`)
- [ ] Absolute URLs for external links
- [ ] Language identifiers in code blocks
- [ ] Escaped emoji in code examples when needed
- [ ] Appropriate table classes for styling
- [ ] One space after sentence punctuation

---

# Buildkite YAML documentation rules

## General YAML writing guidelines

**Refer to meaning, not source:**
- Describe what the YAML represents (command, step, pipeline) rather than the literal YAML syntax
- Never use code formatting when referring to an abstract meaning
- Use code formatting only for literal YAML source or filenames

**Examples:**
- Correct: "Here is an example pipeline configuration…"
- Correct: "Add this step to the pipeline…"
- Incorrect: "Add a `command` to `pipeline.yml`…"

**Avoid YAML specification terminology:**
- Never use: *block*, *flow*, *sequence*, *scalar* as these terms conflict with product terminology or are unclear to users

## YAML code formatting rules

**Always use block-style:**
- Use block-style maps and arrays only
- Never use inline/flow style maps and arrays
- Block, quoted, and unquoted strings are all acceptable

**Correct block style:**
```yaml
steps:
  - label: Tests
    command:
      - npm install
      - npm test
```

**Correct multi-line string:**
```yaml
steps:
  - label: "Tests"
    command: >
      npm run test-runner --
      --with=several
      --arguments
      --split-across-lines-for-readability
```

**Incorrect inline style:**
```yaml
{ steps: [ label: "Tests", command: "npm test" ]}
```

## YAML terminology rules

### Map
**Definition:** A collection of key-value pairs (associative arrays, dictionaries, or objects)

**Usage:**
- Use "map" (noun) only for collections of key-value pairs
- Never use "map" to refer to individual keys or values
- Avoid terms like "block", "section", or "property"

**Examples:**
- Correct: "A command is a map that configures…"
- Incorrect: "Add the `matrix` map to the…"

**Nested Maps:**
- Use "map of maps" or "nested map"
- Qualify relationships with "of"
- Avoid "block", "level", or "sub-" prefix

**Examples:**
- Correct: "The `retry` attribute of a step is a map of maps…"
- Incorrect: "The sub-block contains…"

### Attribute
**Definition:** A key-value pair as a complete unit (not the identifier or value alone)

**Usage:**
- Use "attribute" to refer to the entire key-value pair
- Never use "attribute" for just the key or just the value

**Examples:**
- Correct: "The `steps` attribute determines…"
-  "Add the `steps` attribute to the command step, then on a new line…"

### Key and value
**Definition:**
- Key: The identifier part of an attribute
- Value: The data part of an attribute

**Usage:**
- Use "key" only for the identifier
- Use "value" only for the data
- Always use code formatting for literal keys or values

**Examples:**
- Correct: "Add the `skip` key to the command step, then on a new line…"
- Correct: "Set the value to `true`, `false`, or a string…"
- Incorrect: "Add the skip key to the command step…" (missing code formatting)

### Array
**Definition:** A sequence or list of items

**Usage:**
- Use "array" only for sequences/lists
- Never use "array" for maps
- Avoid terms like "list" or "entries"

**Examples:**
- Correct: "The step attribute consists of an array of step maps…"
- Incorrect: "The attribute contains a list of entries…"

## YAML code examples rules

**Code block requirements:**
- Always use `yaml` language identifier
- Use proper indentation (2 spaces is standard)
- Show realistic, complete examples
- Include context when necessary

**Documentation format:**
```yaml
steps:
  - label: "Example step"
    command: "echo 'Hello World'"
    key: "example-step"
```

## YAML reference checklist

- [ ] Describe YAML meaning, not literal syntax
- [ ] Use code formatting for literal YAML source and filenames
- [ ] Use block-style formatting in all examples
- [ ] Use correct terminology: map, attribute, key, value, array
- [ ] Avoid YAML spec terms: block, flow, sequence, scalar
- [ ] Include `yaml` language identifier in code blocks
- [ ] Use 2-space indentation in YAML examples
- [ ] Qualify nested relationships with "of" or "nested"
- [ ] Never use inline/flow style formatting

## Sensitive information security

### Never include in examples

**Personal/account information:**
- Real API tokens or keys
- Real email addresses
- Real passwords or credentials
- Real account IDs or organization IDs
- Real webhook URLs or endpoints
- Real IP addresses (use RFC 5737 ranges: 192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24)

**Buildkite-specific:**
- Real agent tokens
- Real GraphQL/REST API tokens
- Real build artifacts URLs
- Real SSO/SAML credentials or endpoints
- Real cluster tokens or queue names from production

**Safe Example Patterns:**
- API tokens: `xxx-yyy-zzz` or `YOUR_API_TOKEN`
- Emails: `user@example.com`, `admin@example.org`
- Organizations: `acme-inc`, `example-org`, `your-organization`
- Pipelines: `example-pipeline`, `your-pipeline`
- Webhook URLs: `https://example.com/webhook`
- Build IDs: `01234567-****-****-****-456789abcdef`

**Validation Rules:**
- Check all code examples for realistic-looking tokens
- Verify URLs point to example.com or localhost
- Ensure UUIDs/IDs are clearly placeholder values
- Confirm no internal Buildkite infrastructure details
- Review any copied content for accidental real data

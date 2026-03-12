# AGENTS.md

## Buildkite documentation repository and pipeline

This repository generates the Buildkite documentation website:

https://buildkite.com/docs

- **Repository**: `https://github.com/buildkite/docs`
- **CI**: `https://buildkite.com/buildkite/docs`
- **CI steps**: `.buildkite/pipeline.yml`

There are GitHub Actions workflows but they are not part of the CI pipeline. **Do not use GitHub Actions. EVER.** When asked to do anything with CI use Buildkite. You should have the Buildkite MCP server available. If you don't, and you need CI, STOP and ask the user to set it up:

https://github.com/buildkite/buildkite-mcp-server

Run the CI steps locally and correct any errors before pushing commits. Review the CI build after push.

---

## Understanding Buildkite products and documentation

The other sections in this file cover authoring documentation. This section covers understanding and navigating the Buildkite product documentation as a consumer.

Paths in this section reference files and directories in this repository under `pages/`. To convert a file path to its documentation URL: replace `pages/` with `/docs/`, drop the `.md` extension, and convert underscores to hyphens.

## What the docs cover

The Buildkite documentation at https://buildkite.com/docs covers product usage, configuration, API references, and tutorials. Pricing information is at https://buildkite.com/pricing/ and is not part of this repository.

To discover documentation pages programmatically:

- https://buildkite.com/docs/llms.txt — Index of all pages with brief descriptions to help decide which to fetch
- https://buildkite.com/docs/llms-full.txt — Full rendered content of every page in a single file
- `https://buildkite.com/docs/llms-{slug}.txt` — Topic-specific bundles (see links below and `data/llm_topics.yml` for available slugs)

## Product areas

Buildkite has three main products and shared platform capabilities:

### Pipelines (CI/CD)

The primary product. Start here: `pages/pipelines.md`
For full bundled content, fetch: https://buildkite.com/docs/llms-pipelines.txt

- **Why Buildkite Pipelines**: To understand what differentiates Buildkite from other CI/CD tools, read `pages/pipelines/advantages/buildkite_pipelines.md`. For detailed comparisons, see `pages/pipelines/advantages/buildkite_vs_jenkins.md`, `pages/pipelines/advantages/buildkite_vs_gitlab.md`, and `pages/pipelines/advantages/buildkite_vs_gha.md`. To understand how Buildkite works differently compared to other tools, see https://github.com/buildkite/conversion-rules. Bundled content: https://buildkite.com/docs/llms-why-buildkite-pipelines.txt
- **Hybrid operating model**: Buildkite uses a hosted control plane with a choice of self-hosted or Buildkite-hosted execution. Each job in a pipeline runs on an agent machine. Read `pages/agent.md` for an overview, `pages/agent/self_hosted/` for running your own agents, and `pages/agent/buildkite_hosted/` for using Buildkite-hosted agents. Bundled content: https://buildkite.com/docs/llms-self-hosted-agents.txt and https://buildkite.com/docs/llms-hosted-agents.txt
- **Dynamic pipelines**: A key differentiator. Pipelines can be modified at runtime. Read `pages/pipelines/configure/dynamic_pipelines.md` for the feature overview, `pages/pipelines/tutorials/dynamic_pipelines_and_annotations_using_bazel.md` for a tutorial, and `pages/pipelines/best_practices/working_with_monorepos.md` for monorepo patterns. Bundled content: https://buildkite.com/docs/llms-dynamic-pipelines.txt
- **Concurrency and parallelism**: Buildkite supports large-scale concurrency and multi-environment builds. Read `pages/pipelines/best_practices/parallel_builds.md`
- **Hooks and plugins**: Hooks provide platform-level guardrails, and plugins provide reusable customization. Read `pages/agent/hooks.md` for hooks and `pages/pipelines/integrations/plugins.md` for plugins. Browse available plugins at https://buildkite.com/resources/plugins/ and pipeline examples at https://buildkite.com/resources/examples/
- **Developer experience**: Annotations, structured log output, and embedded links and images reduce log digging. Read `pages/pipelines/configure/annotations.md` for annotations, `pages/pipelines/configure/managing_log_output.md` for log management, and `pages/pipelines/configure/links_and_images_in_log_output.md` for rich log content. Bundled content: https://buildkite.com/docs/llms-developer-experience.txt
- **Creating pipelines**: For pipeline configuration and setup, read `pages/pipelines/configure/`. Bundled content: https://buildkite.com/docs/llms-pipeline-configurations.txt
- **Security**: Read `pages/pipelines/security/` for pipeline security, `pages/pipelines/best_practices/security_controls.md` for security best practices, and `pages/agent/self_hosted/security.md` for self-hosted agent security. For managing secrets, customers can use a secrets plugin (`pages/pipelines/integrations/secrets/plugins.md`) or use Buildkite Secrets (`pages/pipelines/security/secrets.md`). Bundled content: https://buildkite.com/docs/llms-security.txt
- **Migration**: Guides for moving from Jenkins, GitHub Actions, and Bamboo. Read `pages/pipelines/migration/`. Bundled content: https://buildkite.com/docs/llms-migrating-to-buildkite.txt
- **Best practices**: Patterns for pipeline design, agent management, Docker builds, parallelism, monorepos, caching, and more. Read `pages/pipelines/best_practices/`. Bundled content: https://buildkite.com/docs/llms-best-practices.txt
- **Deployments**: Deploying to AWS Lambda, Kubernetes, Argo CD, and Heroku. Read `pages/pipelines/deployments/`. Bundled content: https://buildkite.com/docs/llms-deployments.txt
- **Integrations**: Plugins, notifications, observability, and third-party tools. Read `pages/pipelines/integrations/`. Bundled content: https://buildkite.com/docs/llms-integrations.txt
- **Monorepos**: Change detection and dynamic pipeline patterns for monorepos. Bundled content: https://buildkite.com/docs/llms-monorepos.txt
- **Insights**: Waterfall views, cluster metrics, queue monitoring. Bundled content: https://buildkite.com/docs/llms-insights.txt
- **Governance**: Pipeline templates, build exports, platform controls. Bundled content: https://buildkite.com/docs/llms-governance.txt
- **Debugging**: Guides for debugging and troubleshooting builds, agents, and infrastructure, covering log output management, build annotations, terminal access, agent lifecycle, and platform-specific troubleshooting. Bundled content: https://buildkite.com/docs/llms-debugging.txt

### Test Engine

Tracks and analyzes test suite performance. Start here: `pages/test_engine.md`
Bundled content: https://buildkite.com/docs/llms-test-engine.txt

### Package Registries

Host and manage package registries. Start here: `pages/package_registries.md`
Bundled content: https://buildkite.com/docs/llms-packages.txt

- **Security**: Read `pages/package_registries/security.md` for an overview of Buildkite Package Registries security, `pages/package_registries/security/oidc.md` for OIDC in Package Registries, and `pages/package_registries/security/slsa_provenance.md` for SLSA provenance. Bundled content: https://buildkite.com/docs/llms-security.txt

### Platform (shared features)

Common capabilities across products like organizations, users, permissions, and the CLI. Start here: `pages/platform.md`

- **User and team management**: Permissions, SSO, 2FA, audit log. Bundled content: https://buildkite.com/docs/llms-user-management.txt
- **CLI tools**: The `bk` CLI and `buildkite-agent` CLI reference. Bundled content: https://buildkite.com/docs/llms-cli-tools.txt
- **Security**: Read `pages/platform/team_management/enforce-2fa.md` for enforcing 2FA across the Buildkite platform, `pages/platform/sso.md` for implementing SSO across the Buildkite platform, and `pages/platform/security/tokens.md` for details on Buildkite token types. Bundled content: https://buildkite.com/docs/llms-security.txt

### APIs

REST API and GraphQL API documentation. Start here: `pages/apis.md`
Bundled content: https://buildkite.com/docs/llms-buildkite-apis.txt

For AI-assisted workflows, use the Buildkite MCP server to interact with Buildkite APIs directly. Read `pages/apis/mcp_server.md` for setup and usage. Bundled content: https://buildkite.com/docs/llms-ai-tools-and-mcp.txt

- **Security**: Read `pages/apis/managing_api_tokens.md` for details on managing API access tokens on the Buildkite platform. Bundled content: https://buildkite.com/docs/llms-security.txt

## What is not in the docs

- Pricing and plan details (see https://buildkite.com/pricing/)
- Account management and billing workflows
- Sales and support contact information: to contact support email support@buildkite.com, to contact sales email sales@buildkite.com
- Internal architecture or infrastructure details

For product announcements and technical articles, see the Buildkite blog at https://buildkite.com/resources/blog/

## How pages are structured

Documentation pages live under `pages/` with a directory structure that maps to URL paths. For example, `pages/pipelines/configure/dynamic_pipelines.md` maps to `/docs/pipelines/configure/dynamic-pipelines`.

### Page frontmatter

Some pages include YAML frontmatter at the top of the file:

```markdown
---
toc: false
template: "landing_page"
---
```

Common frontmatter fields:
- `toc`: Show or hide table of contents (`true` or `false`). If a page has no heading level 2s on it (beginning with `##`), ensure `toc: false` has been added to the top of the file.
- `template`: Page layout template (for example, `"landing_page"`)
- `description`: Page description used in metadata

Not all pages have frontmatter. Pages without it use default settings.

### ERB templating

Approximately 20% of `.md` pages contain embedded ERB (`<% %>` and `<%= %>` tags) for dynamic content like tables, conditionals, and shared content rendering. These are processed as ERB despite having a plain `.md` extension. When editing pages with ERB, preserve the template logic.

**Content reuse (snippets/partials):** Reusable content fragments are stored as files prefixed with `_` (for example, `pages/apis/descriptions/_rest_access_token.md`). To include a snippet in a page, use:

```erb
<%= render_markdown partial: 'apis/descriptions/rest_access_token' %>
```

Note: the leading underscore and `.md` extension are omitted in the partial path. Snippet files must not contain headings—add the heading in the main document before the render call.

**Images:** Use the ERB image helper, not Markdown image syntax:

```erb
<%= image "screenshot.png", width: 1820/2, height: 1344/2, alt: "Description of what is shown" %>
```

Image files are stored in `images/docs/` in a subdirectory matching the page's path including its filename. For example, images for `pages/pipelines/insights/queue_metrics.md` go in `images/docs/pipelines/insights/queue_metrics/`. Images must be PNG format with even pixel dimensions for both width and height. Use `width/2, height/2` for retina screenshots.

### Key data files

- `data/nav.yml`: Main site navigation. Every new page needs an entry here to appear in the docs. Each entry is a YAML map with: `name` (required, display text), `path` (URL path after `/docs/`, using hyphens), `children` (nested entries), `pill` (status badge: `beta`, `new`, `coming-soon`, `deprecated`, `preview`), `type` (`dropdown`, `link`, or `divider`), and `start_expanded` (boolean). Omitting `path` creates a section toggle.
- `data/nav_graphql.yml`: Navigation for GraphQL API docs.
- `data/llm_topics.yml`: Defines topic-based `llms-{slug}.txt` endpoints that bundle related pages for LLM consumption. Each topic generates a URL at `https://buildkite.com/docs/llms-{slug}.txt`. Read this file to find available topic slugs and the pages each topic includes.
- `data/llm_descriptions.yml`: Curated page descriptions shown to AI agents to help them decide which pages to fetch.
- `data/tiles.yml`: Tile and card definitions for landing pages (validated by `data/tiles.schema.yml`).
- `data/content/`: Reusable structured content (YAML data files) shared across pages, such as agent configuration attributes, environment variables, and Test Engine fields.
- `data/graphql/`: GraphQL schema data for API documentation.

### Linting

The CI pipeline runs several linters. Run locally before pushing:

- **Vale** (`./scripts/vale.sh`): Spelling and style checker. Add vocabulary exceptions to `vale/styles/vocab.txt`. Add heading case exceptions to `vale/styles/Buildkite/h1-h6_sentence_case.yml`.
- **markdownlint**: Checks Markdown formatting rules (configured in `.markdownlint.yaml`). Files must end with a newline character and have no trailing whitespace.
- **ls-lint**: Enforces filename conventions (configured in `.ls-lint.yml`).

### File naming

Markdown files under `pages/` must use lowercase `snake_case` with the `.md` extension (for example, `dynamic_pipelines.md`, not `DynamicPipelines.md` or `dynamic-pipelines.md`).

---

# Buildkite documentation style rules

## Instructions

When reviewing documentation for style compliance, apply the rules below with 100% accuracy and no omissions or additions. Apply ALL the following rules without exception. Do not infer rules, make assumptions, or rely on general language models’ style preferences. Only follow what is explicitly stated. These rules also apply when writing new documentation.

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

If a rule conflicts with another (for example, clarity vs formatting), prioritize:
- Clarity of user-facing documentation
- Consistency with UI and terminology
- Formatting standards

Do NOT deviate. Do NOT add style suggestions based on general best practices. Only apply the rules outlined below.

Here are the rules:

## Core style and voice

This style guide applies to Buildkite product documentation, API reference pages, step-by-step how-tos, and tutorials.

**Language and voice:**
- Use US English (Merriam Webster)
- Use plain English, avoid unnecessary jargon
- Maintain a semi-formal tone—balance between professional and approachable. From time to time, it is OK to use "don't" instead of "do not," "haven't" instead of "have not," or "didn't" instead of "did not," and so on
- Don't use "delve," "comprehensive," "embark," "leverage," "utilize," "unlock," "harness," or similar buzzwords
- Use active voice whenever possible
- Always use "they" for gender-neutral pronouns, NEVER "he" or "she"
- Don't use phrases like "it's important to note," "it's worth noting," "keep in mind"
- Don't start sentences with "Additionally," "Furthermore," "Moreover"
- Don't use redundant emphasis like "really," "very," or "quite"
- Don't be overly enthusiastic, don't use unnecessary exclamation marks
- Remove hedging phrases like "most of the," "some of the" when they add no precision—for example, write "Most concepts translate" not "Most of the concepts translate"
- Break long compound sentences into shorter ones. When comparing two systems or explaining cause and effect, prefer two sentences over one long sentence joined by a conjunction
- Prefer periods over em dashes when separating independent clauses—split into two sentences instead
- If the verb "display/s" is used intransitively, change it to be in the passive voice or replace this verb with "appear/s", which can be used intransitively.

**Formatting standards:**
- Use sentence case for ALL headings. Only capitalize the first word and proper nouns. Example: "Setting up your first pipeline" not "Setting Up Your First Pipeline".
- Format Buildkite UI/interface elements in **bold** matching exact Buildkite interface capitalization. This formatting applies to Buildkite UI element names (buttons, menu items, field names, tabs, and so on). The only other elements that should be bolded are list items, where each one consists of an initial term (followed by a colon) or sentence, which in turn is usually followed by non-bolded text that defines, describes, or elaborates upon the initially bolded text.
- Format key terms and emphasis in _italics_ (use sparingly)
- Use serial commas when listing items
- Don't use emojis in lists
- In paragraphs—write out numbers up to 10, then use digits. In headings—AVOID digits for numbers smaller than 10
- Use 24-hour time format with timezone (for example, 17:00 AEST)

## Technical writing rules

When writing technical documentation for Buildkite:

**Terminology:**
- "Buildkite agent" or "agent" when referring to the running process
- `buildkite-agent` (in code blocks) when referring to the CLI tool
- "Sign up/log in" (verbs) vs "signup/login" (nouns/adjectives)
- "Time out" (verb) vs "timeout" (noun/adjective)
- Always capitalize: API, SSO, SAML
- Use "Two-factor authentication" (short form: 2FA)
- Use "Single sign-on" (short form: SSO)

**Product-qualified naming:**
- When referring to a specific Buildkite product's features or behavior, use the full product name: "Buildkite Pipelines," "Buildkite Test Engine," and "Buildkite Package Registries." The exception to this is when a full product name has been used for the first time within a page section (which commences with a heading), and then upon subsequent mentions within that page section, the product name can be shortened, without the initial "Buildkite "
- Use bare "Buildkite" only when referring to the company or the overall platform
- This applies to prose, table headers, YAML comments, and comparison content
- Correct: "Buildkite Pipelines runs all steps in parallel by default."
- Incorrect: "Buildkite runs all steps in parallel by default."

**No possessive product names:**
- Never use possessive forms of Buildkite product names—rephrase instead
- Correct: "The syntax used in Buildkite Pipelines is simpler."
- Incorrect: "Buildkite's syntax is simpler."
- Correct: "The Buildkite Pipelines parallel-by-default behavior"
- Incorrect: "Buildkite's parallel-by-default behavior"

**Deprecated terminology:**
- Use "queues" and "agent tokens"—do not prefix with "cluster" (for example, do not write "cluster queues" or "cluster agent tokens"). The "cluster" prefix is deprecated. Also avoid "agent registration tokens" that relate to unclustered agents, which are deprecated.

**Structure:**
- Use bullet lists for unordered items
- Use numbered steps for sequential instructions
- Capitalize first word in lists, use periods only for complete sentences
- Avoid "and/or"—use "or" or rephrase with "or both"
- Use "and" not "&"
- Avoid "we" and "our" in formal documentation
- Avoid exclamation marks in formal content

## Code documentation rules

When documenting code or technical processes for Buildkite:

**Code references:**
- Use code blocks with language identifiers (```yaml, ```bash, and so on)
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
- Proper use of homonyms and words with one character spelling difference (seek vs. sick, though vs. through, and so on)
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
- Proper product name capitalization (for example, "GitHub" not "Github")
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
- [ ] Proper Buildkite terminology (Agent, buildkite-agent, and so on)
- [ ] Product-qualified names ("Buildkite Pipelines," not just "Buildkite")
- [ ] No possessive product names (rephrase "Buildkite's" constructions)
- [ ] No deprecated terminology ("queues" not "cluster queues")
- [ ] Consistent capitalization (GitHub, API, SSO, and so on)
- [ ] Clear structure with appropriate lists
- [ ] Short sentences; break compound comparisons into separate sentences
- [ ] Non-spaced em dashes `—` for asides; prefer periods for independent clauses
- [ ] Avoid "we/our" in formal docs whenever possible
- [ ] Avoid exclamation marks
- [ ] Link key concepts on first mention
- [ ] Plugin links use buildkite.com/resources/plugins/, not GitHub

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

1. Next list item.
```

## Spacing rules

**Sentence spacing:**
- Use only one space after punctuation at end of sentences
- Do not leave trailing spaces at the end of sentences or list items
- Never use double spaces
- Never leave consecutive blank lines in Markdown files. Use exactly one blank line to separate elements

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

**Plugin links:**
- Link to Buildkite's plugin directory at `https://buildkite.com/resources/plugins/` rather than directly to GitHub repositories
- Correct: `[Docker Compose plugin](https://buildkite.com/resources/plugins/docker-compose)`
- Incorrect: `[Docker Compose plugin](https://github.com/buildkite-plugins/docker-compose-buildkite-plugin)`

**First mentions:**
- When a key concept (like "environment variables," "dynamic pipelines," or "plugins") is first mentioned on a page, link it to the relevant documentation page
- Correct: "Buildkite Pipelines provides [environment variables](/docs/pipelines/configure/environment-variables):"
- Incorrect: "Buildkite Pipelines provides environment variables:"
- Only link the first mention—do not repeat the link on subsequent mentions of the same term

**Link verification:**
- Always verify that link targets resolve to actual pages before merging. Broken links from moved or deleted content are a recurring issue

## Callout rules

**When to use callouts:**
- Use info callouts (📘) for notes, tips, or supplementary information
- Use warning callouts (🚧) for warnings, cautions, or troubleshooting tips
- Do NOT use bolded labels like `**Note:**` or `**Warning:**` followed by text in paragraphs—use callouts instead

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
- Within numbered lists, use indented bold text instead of emoji callouts
- This is the ONE exception where `**Note:**` is acceptable
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

**Content ordering:**
- Lead with the most useful action-oriented content (for example, "how to publish," "how to configure")
- Move prerequisites, format requirements, and reference material after the introductory action-oriented sections
- Do not front-load a page with constraints or limitations before showing the reader what they can do

**Introductory paragraphs:**
- When a heading contains a group of subsections (for example, a list of API endpoint groups or feature categories), add a brief introductory paragraph explaining the organizational structure before the subsections
- Do not jump directly from a heading into subheadings without context

**Nesting new content:**
- When adding new content, place it under existing headings where it logically belongs rather than creating new top-level sections
- This keeps the document hierarchy clean and avoids unnecessary heading proliferation

## Markdown syntax checklist

- [ ] Headings nested incrementally (H1 → H2 → H3 → H4)
- [ ] Empty lines above and below headings
- [ ] Sentence case headings without punctuation
- [ ] `**bold**` for Buildkite UI elements only, `_italics_` for key terms
- [ ] `-` for top-level lists, `*` for 2nd level, `-` for 3rd level
- [ ] 4-space indentation for nested lists and paragraphs
- [ ] `1.` for all numbered list items
- [ ] Relative URLs for internal links (`/docs/...`)
- [ ] Absolute URLs for external links
- [ ] Plugin links point to buildkite.com/resources/plugins/, not GitHub
- [ ] Key concepts linked on first mention
- [ ] All link targets verified as valid
- [ ] Language identifiers in code blocks
- [ ] Escaped emoji in code examples when needed
- [ ] Appropriate table classes for styling
- [ ] One space after sentence punctuation
- [ ] No consecutive blank lines
- [ ] Sections with subsections have introductory paragraphs
- [ ] Action-oriented content before prerequisites and reference material

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
- Correct: "Add the `steps` attribute to the command step, then on a new line…"

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

**YAML comments:**
- Use product-qualified names in YAML comments, just as in prose (for example, `# Buildkite Pipelines equivalent` not `# Buildkite equivalent`)
- Keep comments concise and descriptive

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
- [ ] Product-qualified names in YAML comments

---

# Sensitive information security

## Never include in examples

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

If asked to rewrite a document based on these instructions:
Use natural writing style. Write like a human technical writer, not like AI. AVOID AI WRITING PATTERNS!

---

# Session completion

## Landing the plane

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work**: Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed): Tests, linters, builds
3. **Update issue status**: Close finished work, update in-progress items
4. **PUSH TO REMOTE**: This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up**: Clear stashes, prune remote branches
6. **Verify**: All changes committed AND pushed
7. **Hand off**: Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing—that leaves work stranded locally
- NEVER say "ready to push when you are"—YOU must push
- If push fails, resolve and retry until it succeeds

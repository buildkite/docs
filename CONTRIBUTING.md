# Contributing to the Buildkite Docs

This guide provides details on how to work with the Buildkite Docs source code, which generates the [Buildkite Docs](https://buildkite.com/docs/) web site, and make contributions to its content.

Please also note the following style guides, which are relevant to adding content to pages within this site:

- [Writing style guide](./styleguides/writing-style.md)
- [Markdown syntax style guide](./styleguides/markdown-syntax-style.md)

## Working with the docs site

The Buildkite docs is a custom-built website. This section gives some guidance on working with the setup.

As a public contributor to the Buildkite Docs, you should work with a fork of [this upstream repository](https://github.com/buildkite/docs) in your own GitHub account, and then create pull requests to this upstream.

### Add a new docs page and nav entry

To add a new documentation (docs) page and a nav entry for it:

1. Create the file as a new Markdown file (with the extension `.md`) within the appropriate `pages` directory. Ensure the file name is written in all lowercase letters, and separate words using underscores. (These underscores will be automatically converted to hyphens when the Buildkite Docs site is rebuilt.)

1. Add a corresponding entry to this new page in the [`./data/nav.yml`](./data/nav.yml) file, which adds a new entry for this page in the page navigation sidebar (nav) of the [Buildkite Docs site](https://buildkite.com/docs). Note the existing page entries in `nav.yml` and use them as a guide to determine the location and hence, placement of the entry to your new Markdown file (in the nav and `nav.yml`). The following elements require considering for a new entry in `nav.yml`:

    | Key           | Description | Data type |
    | ------------- | ----------- | --------- |
    | `name`        | Nav entry name (see note below). | String, required |
    | `path`        | Enter a relative URL path for internal pages. You can also prepend with `https` for external pages, or `mailto:` for email links, although this practice should be avoided or minimized. If the `path` is empty or omitted, then this will be rendered as a toggle that opens a new section of pages. | String, optional |
    | `icon`        | Prepend with an icon. | String, optional |
    | `theme`       | WIP: doesn't work yet. Apply a theme. You can use `green` or `purple`. | String, optional |
    | `children`    | Child nav entry items. | Array of objects, optional |
    | `pill`        | Append a pill to indicate the status of a page and its content. Currently, using `beta`, `coming-soon`, `deprecated` or `new` will generate pills that have color formatting. You can also use the pill `preview` to indicate that a page's content, along with the feature it documents, is still in development. | String, optional |
    | `new_window`  | Make this link open up a new window, although this practice should be avoided or minimized. | Bool, optional |
    | `type` | Special nav link types. With `dropdown` the children nav items will be rendered as hover dropdown menus on laptop/desktop screen devices. `link` is a shortcut link that takes the user from one section to another (for example, you may link to SSO under the Integrations section from Pipeline's sidebar). It also renders an 'external link' icon as an affordance. Lastly, `divider` makes a divider line in the nav to help with visual delineation. | String, `dropdown|link|divider`, optional |

> [!NOTE]
> Whenever you save changes to the `nav.yml` file, you'll need to stop and restart your local development environment in order to see these changes reflected in the nav.
>
> The Buildkite Docs web site is kept running with Ruby, which interprets underscores in filenames as hyphens. Therefore, if a page is called `octopussy_cat.md`, then for its entry in the `nav.yml` file, you need to reference its `path` key value as `octopussy-cat`.
>
> If you're creating a new section for the nav, then as described for the `path` key above, add the `name` key for this entry, omit its `path` key, and add a `children` key to create this new section. Then, nest/indent all new page entries within this section entry.
>
> Since a new section entry in the nav is purely a toggle that cannot hold page content itself, then to introduce a page for this new section, create a top-level "Overview" page for this section instead.

### Linting

This section describes the various linting features which are run as part of the Buildkite Docs build pipeline.

The docs (in US English) are spell-checked and a few automated checks for repeated words, common errors, and Markdown and filename inconsistencies are also run.

You can run most of these checks locally with [`./scripts/vale.sh`](./scripts/vale.sh).

#### Markdown files

Markdown files must be located within `pages`, and their names must be written in [`snake_case`](https://simple.wikipedia.org/wiki/Snake_case) and end with the `.md` extension.

The [`.ls-lint.yml`](.ls-lint.yml) linter file contains rules that the ls-lint filename linter checks are observed.
Learn more about the [ls-lint filename linter](https://ls-lint.org/1.x/getting-started/introduction.html).

#### Markdown content

A [Markdown linter](https://github.com/DavidAnson/markdownlint) also runs on the Buildkite documentation's Markdown file content.

The rules enabled for this Markdown linting are defined in the [`.markdownlint.yaml`](.markdownlint.yaml) file.

For the linter jobs to pass, every line in a Markdown file must not end in any trailing spaces, and the last character in the Markdown file must be a new line character.

#### Fix spelling errors

The Buildkite Docs build pipeline uses [Vale](https://vale.sh/) to check for spelling errors, and builds will fail if a spelling error is encountered. Vale also checks for incorrect letter case handling, for example, Proper Nouns that should be treated as common nouns.

If you need to add an exception to this (for example, you are referencing a new technology or tool that isn't in Vale's vocabulary), add this term verbatim to the [`./vale/styles/vocab.txt`](./vale/styles/vocab.txt) file, ensuring that the term is added in the correct alphabetical order within the file. Case is important but should be ignored with regard to alphabetical ordering within the file. This makes it easier to identify if an exception has already been added.

If you encounter a spelling or letter case handling error within a heading, add this entry into the [`./vale/styles/Buildkite/h1-h6_sentence_case.yml`](./vale/styles/Buildkite/h1-h6_sentence_case.yml) file.

#### Escape vale linting

If you absolutely need to add some word or syntax that would trigger the linter into failing the docs build pipeline, you can use escaping using the following syntax:

```
<!-- vale off -->

This is some text that you do NOT want the linter to check

<!-- vale on -->
```

Use the `vale off` syntax before a phrase that needs to be bypassed by the linter and don't forget to turn it on again with `vale on`.

### Content reuse (snippets/partials)

You can use snippets (also known as partials) to reuse the same fragment of text in several documentation pages (single sourcing). This way, you can update the snippet once, and the changes will be visible on all pages that use this snippet.

Add snippet files to appropriate locations within the `/pages` directory, prefaced with an underscore in the file name. For example `_my_snippet.md`. **However**, when pulling the snippet into a file, remove the leading underscore.

This way, the following example snippet file located immediately within the `/pages` directory:

`_step_2_3_github_custom_status.md`

is referenced using this snippet render link:

`<%= render_markdown partial: 'step_2_3_github_custom_status' %>`

Use the snippet render link wherever you need to add the content of the snippet (multiple times if required) in other Markdown files throughout the Buildkite Docs.

If a snippet is stored within a subdirectory of `/pages`, you need to specify the subdirectory hierarchy in the link to the snippet.

Therefore, a reference to the `_agent_events_table.md` file stored within the `webhooks/pipelines` subdirectory of the `apis` subdirectory would look like this:

`<%= render_markdown partial: 'apis/webhooks/pipelines/agent_events_table' %>`

> [!WARNING]
> **The snippets/partials feature currently has the following limitations**
> - Headings are not supported. Using H2, H3-level headings within the snippet content can lead to incorrect anchor links being generated for them. Additionally, using any heading level within a snippet prevents these headings from appearing in the **On this page** feature. Instead, add the heading to the main document just before you add a snippet render link, with the snippet only containing the text content you want to reuse.
> - Snippets don't support conditional content. You cannot use variables to represent conditional content within a snippet. If you have content in a snippet where some of its content (such as a small number of words) needs to be changed depending on where the snippet is used, for example, a product name, you'll either need to create multiple snippets for each usage and reference them accordingly on their respective pages, or alternatively, write the content directly into their respective pages.

### Custom elements

The Buildkite docs has a few custom scripts for adding useful elements that are missing in Markdown.
To save yourself a few unnecessary rounds of edits in the future, remember that if you see a fragment written in HTML, links within such fragment should also follow the HTML syntax and not Markdown (more on this in [Note blocks](#note-blocks)).

#### Beta flags

To mark a content page in the site as being in beta, add its relative path _after_ `docs` to the [`./app/models/beta_pages.rb`](./app/models/beta_pages.rb) file.

For example:
```
[
  'pipelines/some-new-beta-feature',
  'test-engine/some-new-beta-feature',
  'package-registries/some-new-beta-feature'
]
```

Any file listed there will automatically pick up the beta styling.

Adding the class `has-pill-beta` to any element will append the beta pill. This is intended for use in the sidebar and homepage navigation and will not work in Markdown.

#### Table of contents

An in-page table of contents (with the **On this page** title) is automatically generated based on `##`-level headings.

You can omit a table of contents by adding some additional metadata to a Markdown template using the following YAML front matter:

```yaml
---
toc: false
---
```

#### Prepend icons

You can prepend an icon to boost the visual emphasis for an inline text. To do this, wrap the text with `<span class="add-icon-#{ICON_NAME}">`.

At the time of writing, there are only three icons available — agent, repository, and plugin. To add more icons see `$icons` in `_add-icon.scss`, add a new name as the key and the inline SVG. Icon dimension must be 22px * 22px.

> [!NOTE]
> Unlike emojis, these icons are generic and contextual, and they are used as to help readers to better visually differentiate specific terms from the rest of the text.

### Update Buildkite Agent CLI docs

The [Buildkite Agent command-line interface (CLI) reference docs](https://buildkite.com/docs/agent/cli/reference) consists of a series of pages where each page describes how each of the agent's `buildkite-agent` CLI commands works and is used.

Each command's docs page should have a **Usage**, **Description**, **Example**, and **Options** section appearing somewhere on the page.

These four sections are actually part of a [partial](#content-reuse-snippetspartials), whose content comes from its relevant Markdown file partial in the [docs source repo's `pages/agent/help` folder](./pages/agent/help). The files in this folder are automatically updated whenever a [new version of the Buildkite Agent is released](https://github.com/buildkite/agent/releases), containing updates to the documentation in any of its relevant [clicommand files](https://github.com/buildkite/agent/tree/main/clicommand). This is why the tops of these file partials indicate **DO NOT EDIT**.

With the development dependencies installed you can update these CLI docs locally with the following:

```bash
# Set a custom PATH to select a locally built buildkite-agent
PATH="$HOME/Projects/buildkite/agent:$PATH" ./scripts/update-agent-help.sh
```

### Update the GraphQL API docs

The GraphQL API reference documentation (from the start of [Queries](https://buildkite.com/docs/apis/graphql/schemas/query/agent) through to end of [Unions](https://buildkite.com/docs/apis/graphql/schemas/union/usageunion)) is generated from a local version of the [Buildkite GraphQL API schema](./data/graphql/schema.graphql).

This repository is kept up-to-date with production based on a daily scheduled build that generates a pull request. The build fetches the latest GraphQL schema from the Buildkite API, generates the documentation, and publishes a pull request for review.

If you need to fetch the latest schema, you can run the following in your local environment:

```sh
# Fetch latest schema
API_ACCESS_TOKEN=xxx  bundle exec rake graphql:fetch_schema >| data/graphql/schema.graphql

# Generate docs based on latest schema
bundle exec rake graphql:generate
```

### Update vendor/emojis

From time to time, you will start seeing an update to `vendor/emojis` submodule as a default initial file change in every new branch you create. This happens because these new branches will have an older version of the emoji submodule than the main branch.

**Do not commit the `vendor/emojis` commit!** Instead, run `git submodule update`. This will take care of the emoji commit - until your local emoji submodule version falls behind again. Then you will need to run `git submodule update` for your local Docs repository again.

If you do accidentally commit the `vendor/emojis` update, use `git reset --soft HEAD~1` to undo your last commit, un-stage the erroneous submodule change, and commit again.

### Search index

**Note:** By default, search (through Algolia) references the production search index.

The search index is updated once a day by a scheduled build using the config in `config/algolia.json`.

To test changes to the indexing configuration:

1. Make sure you have an API key in `.env` like:

    ```env
    APPLICATION_ID=APP_ID
    API_KEY=YOUR_API_KEY
    ```

2. Run `bundle exec rake update_test_index`.

### Content keywords

Content keywords are rendered in `data-content-keywords` in the `body` tag to highlight the focus keywords of each page with content authors.

This helps the main documentation contribution team quickly inspect to see the types of content Buildkite provides across different channels.

Keywords are added as [Frontmatter](https://rubygems.org/gems/front_matter_parser) meta data using the `keywords` key, e.g.:

```md
keywords: docs, tutorial, pipelines, 2fa
```

If no keywords are provided it falls back to comma-separated URL path segments.

## Screenshots

This information was aggregated by going over the existing screenshots in the documentation repo. Feel free to change or expand it.

### Taking and processing screenshots

* **Format:** PNG
* **Ratio:** arbitrary, but **strictly even number of pixels** for both height and width. Recommended size `width: 1024px, height: 880px` when you're taking a full-width screen
* **Size:** the largest possible resolution that makes sense. It's preferable that you take the screenshots on a Mac laptop with a Retina or high-resolution display/screen. Recommended dimension is `width: 2048/2, height: 880/2` to get the best possible view across different screen sizes.
* **No feature flag:** please remember to turn off all experimental features when taking screenshots
* **Border:** no border
* **Drop shadow:** no
* **Cursor:** include when relevant
* **Area highlight selection:** subtract overlay
* **Blur:** use to obscure sensitive info like passwords or real email addresses; even, non-pixelated
* **User info:** blur out everything except for the name
* **Dummy data:** use Acme Inc as dummy company title
* **Naming screenshots:** lowercase, words separated by hyphens; number after the title, for example, "installation-1"

### Adding screenshots or other images

> Before you proceed, make sure that both the width and the height of the image are an even number of pixels!

Steps for adding add an image to a documentation page:

1. Name the image file (lowercase, separate words using hyphens; add a number to the filename, for example, 'installation-1' if you are adding several images to the same page).

1. Save the file into its corresponding folder within `/images/docs`. This folder is a sub-folder within `/images/docs` whose path matches that of the Markdown page's path within `/pages`, _which includes_ the file name of Markdown page that this image file is referenced on, as the final sub-folder. Create this sub-folder hierarchy if it doesn't yet exist within `/images/docs`.

    For example, if you add an image called `my_image.png` to a page located in the path `/pages/pipelines/insights/queue_metrics.md`, then save the actual image file to the path `/images/docs/pipelines/insights/queue_metrics/my_image.png`.

1. Compose relevant alt text for the image file using sentence case.

1. Add your image file to the documentation page using the following code example `<%= image "your-image.png", width: 1110, height: 1110, alt: "Screenshot of Important Feature" %>`.
For large images/screenshots taken on a retina screen, use `<%= image "your-image.png", width: 1110/2, height: 1110/2, alt: "Screenshot of Important Feature" %>`.

## Talking about YAML

YAML looks more simple than it is.
It takes some care and discipline to write about.
See [Talking about YAML](./yaml.md) for complete guidance.

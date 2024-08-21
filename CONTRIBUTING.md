# Contributing to the Buildkite Docs

This guide provides details on how to work with the Buildkite Docs source code, which generates the [Buildkite Docs](https://buildkite.com/docs/) web site.

Please also note the following style guides, which are relevant to adding content to pages within this site:

- [Writing style guide](./styleguides/writing-style.md)
- [Markdown syntax style guide](./styleguides/markdown-syntax-style.md)

## Working with the docs site

The Buildkite docs is a custom-built website. This section gives some guidance on working with the setup.

### Adding and naming new documentation pages

To add a new documentation page, create it as a *.md file. Give it a lowercase name, separate words using underscores.
To add the new page to the documentation sidebar on https://buildkite.com/docs, add the corresponding entry to
`data/nav.yml` with the following data in the sitetree:

| Key           | Description | Data type |
| ------------- | ----------- | --------- |
| `name`        | Menu name | String, required |
| `path`        | Enter a relative URL path for internal pages. You can also prepend with `https` for external pages, or `mailto:` for email links. If Path is empty then this will be rendered as a toggle. | String, optional |
| `icon`        | Prepend with an icon | String, optional |
| `theme`       | WIP: doesn't work yet. Apply a theme. You can use `green` or `purple` | String, optional |
| `children`    | Children menu items | Array of objects, optional |
| `pill`        | Append a pill. Currently you can use `beta`, `coming-soon`, `deprecated` or `new` | String, optional |
| `new_window`  | Make this link open up a new window | Bool, optional |
| `type` | Special nav link types. With `dropdown` the children nav items will be rendered as hover dropdown menus on laptop/desktop screen devices. `link` is a shortcut link that takes the user from one section to another (for example, you may link to SSO under the Integrations section from Pipeline's sidebar). It also renders an 'external link' icon as an affordance. Lastly, `divider` makes a divider line in the nav to help with visual delineation. | String, `dropdown|link|divider`, optional |

> [!NOTE]
> Ruby, which keeps the website running, interprets underscores in filenames as hyphens. So if a page is called `octopussy_cat.erb.md`, you need to add it as `octopussy-cat` to the `nav.yml` file.

### Filenames and filename linting

Use `snake_case` for `*.md` files in `pages`. The [`.ls-lint` linter](https://github.com/buildkite/docs/blob/main/.ls-lint.yml) checks if this rule is observed.
See more about the [ls-lint filename linter](https://ls-lint.org/1.x/getting-started/introduction.html).

### Escaping vale linting

If you absolutely need to add some word that triggers the linter, you can use escaping using the following syntax:

```
<!-- vale off -->

This is some text that you do NOT want the linter to check

<!-- vale on -->
```

Use the `vale off` syntax before a phrase that needs to be bypassed by the linter and don't forget to turn it on again with `vale on`.

### Markdown linting

A [Markdown linter](https://github.com/DavidAnson/markdownlint) is at work in Buildkite documentation.

The enabled Markdown linting rules are in [`.markdownlint.yaml`](https://github.com/buildkite/docs/blob/main/.markdownlint.yaml) file.

### Content reuse (snippets)

You can use snippets to reuse the same fragment in several documentation pages (single sourcing). This way, you can update the snippet once, and the changes will be visible on all pages that use this snippet.

Add snippet files to appropriate locations within the `/pages` directory, prefaced with an underscore in the file name. For example `_my_snippet.md`. **However**, when pulling the snippet into a file, remove the leading underscore.

This way, the following example snippet file located immediately within the `/pages` directory:

`_step_2_3_github_custom_status.md`

is referenced using this snippet render link:

`<%= render_markdown partial: 'step_2_3_github_custom_status' %>`

Use the snippet render link wherever you need to add the content of the snippet (multiple times if required) in other Markdown files throughout the Buildkite Docs.

If a snippet is stored within a subdirectory of `/pages`, you need to specify the subdirectory hierarchy in the link to the snippet.

Therefore, a reference to the `_agent_events_table.md` file stored within the `webhooks` subdirectory of the `apis` subdirectory would look like this:

`<%= render_markdown partial: 'apis/webhooks/agent_events_table' %>`

> [!WARNING]
> Do not use H2, H3-level headings in the first line of a snippet because this results in the generation of incorrect anchor links for such headings. Instead, if you need to start a snippet with a heading, add the heading to the main document just before you add a snippet render link.

### Custom elements

The Buildkite docs has a few custom scripts for adding useful elements that are missing in Markdown.
To save yourself a few unnecessary rounds of edits in the future, remember that if you see a fragment written in HTML, links within such fragment should also follow the HTML syntax and not Markdown (more on this in [Note blocks](#note-blocks)).

#### Beta flags

To mark a content page in the site as being in beta, add its relative path _after_ `docs` to the `app/models/beta_pages.rb` file.

For example:
```
[
  'test-analytics',
  'test-analytics/integrations'
]
```

Any file listed there will automatically pick up the beta styling.

Adding the class `has-pill-beta` to any element will append the beta pill. This is intended for use in the sidebar and homepage navigation and will not work in Markdown.

#### Table of contents

Table of contents are automatically generated based on \##\-level headings.

You can omit a table of contents by adding some additional metadata to a Markdown template using the following YAML front matter:

```yaml
---
toc: false
---
```

#### Prepending icons

You can prepend an icon to boost the visual emphasis for an inline text. To do this, wrap the text with `<span class="add-icon-#{ICON_NAME}">`.

At the time of writing, there are only three icons available — agent, repository, and plugin. To add more icons see `$icons` in `_add-icon.scss`, add a new name as the key and the inline SVG. Icon dimension must be 22px * 22px.

> [!NOTE]
> Unlike emojis, these icons are generic and contextual, and they are used as to help readers to better visually differentiate specific terms from the rest of the text.

### Updating vendor/emojis

From time to time, you will start seeing an update to `vendor/emojis` submodule as a default initial file change in every new branch you create. This happens because these new branches will have an older version of the emoji submodule than the main branch.

**Do not commit the `vendor/emojis` commit!** Instead, run `git submodule update`. This will take care of the emoji commit - until your local emoji submodule version falls behind again. Then you will need to run `git submodule update` for your local Docs repository again.

If you do accidentally commit the `vendor/emojis` update, use `git reset --soft HEAD~1` to undo your last commit, un-stage the erroneous submodule change, and commit again.

## Screenshots

This information was aggregated by going over the existing screenshots in the documentation repo. Feel free to change or expand it.

### Taking and processing screenshots

* **Format:** PNG
* **Ratio:** arbitrary, but **strictly even number of pixels** for both height and width. Recommended size `width: 1024px, height: 880px` when you're taking a full-width screen
* **Size:** the largest possible resolution that makes sense. It's preferable that you take the screenshots on a Mac laptop with a Retina screen using Safari. Images should be exported at double (`@2x`) the original screen. Recommended dimension is `width: 2048/2, height: 880/2` to get the best possible view across different screen sizes.
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
1. Name the image file (lowercase, separate words using hyphens; add a number to the filename, for example, 'installation-1' if you are adding several images to the same page)
2. Put the file into the corresponding `images` folder (a folder with the same name as the page you are adding this image to; create such folder if it doesn't exist yet)
3. Compose relevant alt text for the image file using sentence case
4. Add your image file to the documentation page using the following code example `<%= image "your-image.png", width: 1110, height: 1110, alt: "Screenshot of Important Feature" %>`.
For large images/screenshots taken on a retina screen, use `<%= image "your-image.png", width: 1110/2, height: 1110/2, alt: "Screenshot of Important Feature" %>`.

## Talking about YAML

YAML looks more simple than it is.
It takes some care and discipline to write about.
See [Talking about YAML](./yaml.md) for complete guidance.

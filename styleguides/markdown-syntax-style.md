# Markdown syntax style guide

Welcome to the Buildkite Markdown syntax style guide.

These guidelines provide details about the specific Markdown syntax used to write the Buildkite docs, as well as its file structure and how to work with the site (useful to understand when adding new pages), and screenshots.
If something isn't included in this guide, see the [Google developer documentation style guide](https://developers.google.com/style), followed by the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/).

For details about the language, words, and writing style and format used to write the Buildkite docs, refer to the [Writing style guide](writing-style.md).

Table of contents:

- [Style and formatting](#style-and-formatting) <!-- * [Code and filenames](#code-and-filenames) -->
- [Working with the docs site](#working-with-the-docs-site)
- [Screenshots](#screenshots)
- [Talking about YAML](#talking-about-yaml)

## Style and formatting

This section covers the Markdown syntax associated with the [Style and formatting in the Writing style guide](writing-style.md#style-and-formatting).

### Markdown

The docs website uses the [Redcarpet](https://github.com/vmg/redcarpet) Ruby library for Markdown.
Redcarpet does not conform with the CommonMark or GitHub Flavored Markdown specifications.
Watch out for differences such as:

- Inline HTML comments are escaped and will appear in the output, but block comments won't.

  ```markdown
  Hello world! <!-- this comment is visible to readers -->

  <!-- This comment is hidden -->
  ```

- See below about [new paragraphs within a list item](#new-paragraphs-within-a-list-item).

### Headings

Ensure headings are always nested incrementally within any Markdown page (that is, `# Heading (used as the page title)`, `## Heading`, `### Heading`, `#### Heading`, etc.) throughout the docs. Be aware that this incremental nesting rule can be broken on the way up. For example:

```
# Heading level 1 used as the page title

Some text.

## Heading level 2

More text.

### Heading level 3

Even more text.

#### Heading level 4

...

#### Another heading level 4

...

## Another heading 2

...
```

> [!NOTE]
> To improve the readability of the Markdown source content, ensure there is an empty line inserted both above and below the heading.
>
> To avoid over-complicating the structure of a page, do not descend any further than a heading level 4. Be aware that only heading level 3s are rendered in the right **On this page** sections of pages in the Buildkite Docs.
>
> In line with [Google's developer docs guidelines on heading/title formatting](https://developers.google.com/style/headings#heading-and-title-format), avoid using `code` items in headings. However, if you do wish or need to do so, don't use code formatting in the heading text. Also avoid other fancy formatting such as **bold** or _italics_ in heading text.

Refer to [Headings in the Writing style guide](writing-style.md#headings) for details on how to write and present headings in the Buildkite docs.

### New paragraphs

To create a new paragraph of text, add two line breaks at the end of the last character of the previous paragraph, effectively creating an additional empty line, and continue with the new paragraph.

> [!NOTE]
> Do not attempt to create single line breaks within a paragraph of text. While this is possible using the `<br/>` HTML element in the Markdown syntax flavor used for the Buildkite Docs, doing this adds little value to the text and [may impact how text is displayed on different devices](https://developers.google.com/style/paragraph-structure).

#### New paragraphs within a list item

Four spaces are required to create a new paragraph within/as part of a list item. If you don't do this, the new paragraph will break out of and interrupt the list.

**✅ Do this**
```markdown
1. First paragraph of this list item.

    A happy second paragraph, indented four spaces.
```

**❌ Don't do this**
```markdown
1. First paragraph of this list item.

   A sad, broken second paragraph, indented three spaces.
```

### Spacing after the end of a sentence

**Question:** Should you use one, two or more spaces after punctuation at the end of a sentence?

**Answer:** One space.

Here is some [historical background](https://www.onlinegrammar.com.au/the-grammar-factor-spacing-after-end-punctuation-capitals/) on why this is even a valid question.

### UI elements

UI element references are formatted using bold in the Buildkite docs. Markdown supports two consecutive asterisks `**` or underscores `__` as its markup for bold text. For consistency, use sets of two consecutive asterisks `**` immediately surrounding the text you want to bold. For example, `**Bold this text**`.

Refer to [Referring to UI elements in the Writing style guide](writing-style.md#ui-elements) for details on how to write and present UI elements in the docs.

### Key terms and emphasis

Key terms and emphasized words are formatted using italics in the Buildkite docs. Markdown supports two characters as its markup for italicizing text—either an underscore `_` or a single asterisk `*`. For consistency, use single underscores `_` immediately surrounding the text you want to italicize. For example, `_Italicize this text_`.

Refer to [Referring to Key terms in the Writing style guide](writing-style.md#key-terms) for details on how to write and present key terms in the docs.

### Lists

For a bulleted/unordered list item, use a single hyphen `-` at the start of a new line (that is, for a top-level list item), followed by a single space, followed by the text for that bullet point. For a nested bulleted list item, begin with an indented single asterisk `*` at the start of a new/indented text block. If a 3rd-level nested bullet list item needs to be created, begin it with a single `-` again.

Nest bullet list items using exactly 4-space indent increments. For example:

```markdown
- Top-level bullet list item

    * 2nd-level bullet list item
    * Another 2nd-level item

        - 3rd-level bullet list item
        - Another 3rd-level item

- Another top-level bullet list item
- And yet another.
...
```

Some existing bullet lists in the docs use only 2-space indent increments. This style is deprecated and over time, these will be changed to a 4-space indent increments.

For a numbered list item, use the syntax `1.` at the start of a new line (or block), followed by a single space, followed by the text for that numbered list item.
For subsequent items in a numbered list, start the new line/block with `1.` again, as the HTML will always render subsequent items sequentially. Avoid attempting to number each item sequentially (for example, `2.`, `3.`, etc.), regardless of the incremental interval (for example, `1.`, `10.`, `20.`, etc.). This makes it easier to insert items without having to renumber adjacent list numbered items.

Refer to [Lists in the Writing style guide](writing-style.md#lists-bullet-lists-and-numbered-steps) for details on how to write and present lists in the Buildkite docs.

### Links

#### Internal links to other pages

From within the Buildkite Docs, when linking to other pages within the Buildkite Docs, use relative (not absolute) URL/links. These relative links start from the `/docs` part of the URL.

For example:

```
Learn more about [environment variables](/docs/pipelines/environment-variables).
```

Do not make these links absolute ones. For example, avoid absolute links like:

```
Learn more about [environment variables](https://buildkite.com/docs/pipelines/environment-variables).
```

or

```
Learn more about [environment variables](http://localhost:3000/docs/pipelines/environment-variables).
```

the latter of which would only work in your local Buildkite Docs development server environment, and be broken anywhere else.

**Why relative links?** Relative links behave the same way when used within the Buildkite Docs development server environment ('local environment') as they do in the official Buildkite docs. Absolute links accessed from the local environment would lead to pages in the official Buildkite docs site, impairing the local development experience. Also, if any parts of the URL change (the base/parts of the domain, while unlikely or a fundamental part of the URL path), it would be easier to maintain these links (for example, via a global search-and-replacement throughout the docs source), than having to search and replace Buildkite Docs URLs containing `buildkite.com`, some of which may not be internal links (see [below](#external-links)).

#### Internal anchor links

From within the Buildkite Docs, when linking to headings on other pages within the Buildkite docs, when linking to an H2-level heading, append the section's name (in [kebab case](https://en.wikipedia.org/wiki/Letter_case#Kebab_case) following a `#`) to the main page link. For example:
`/docs/pipelines/secrets` will contain `/docs/pipelines/secrets#using-a-secrets-storage-service`. These parts of URLs downstream of (and including) the `#` are known as URL fragments.

When linking to an H3-level heading, start with an H2-level anchor link. Such links are generated automatically from the section title, and are viewable in the `#` that appears when you hover your mouse pointer over the heading. Add a `-` to the H2-level anchor link, and append the full name of the H3-level title to it (again in kebab case). The result will be a longer link. For example:

`/docs/pipelines/environment-variables#environment-variable-precedence-job-environment`

Here the H2-level link for `## Environment variable precedence` is `/docs/pipelines/environment-variables#environment-variable-precedence` and the H3-level link for `### Job environment` is appended as `-job-environment`.

> [!TIP]
> A quick way to obtain the URL fragment of a page heading within the Buildkite Docs is to hover your mouse pointer over the heading, when the link icon appears to the left of the heading, select it and then copy of the URL fragment from your browser's URL field.
> Alternatively, select the relevant heading from the right _On this page_ section of the page and copy the URL fragment from your browser's URL field.

#### External links

From within the Buildkite Docs, when linking to other pages/URLs on external sites, always use the full/absolute URL. This includes other Buildkite sites (that is, the main web site), Buildkite blog, Buildkite changelogs, Twitter/X. For example, use external links like:

The Buildkite home page:
```
https://buildkite.com/home
```

Buildkite blog:
```
https://buildkite.com/blog
```

Wikipedia entries:
```
https://en.wikipedia.org/wiki/Twitter
```

### Callouts

Callouts are also known as admonitions.

Currently, callouts in the Buildkite Docs are generated through a combination of Markdown blockquote syntax with a particular emoji.

A regular info callout ("purple"):

```
> 📘 An info callout title
> Callout content can have `code` or _emphasis_ and other inline elements in it, [including links](#).
> Every line break after the first becomes a new paragraph inside the callout.
```

This will be rendered as the following HTML in the site:

```
<section class="callout callout--info">
  <p class="callout__title" id="a-callout-title"📘 An info callout title</p>
  <p>Callout content can have <code>code</code> or <em>emphasis</em> and other inline elements in it, <a href="#">including links</a></p>
  <p>Every line break after the first becomes a new paragraph inside the callout.</p>
</section>
```

> [!NOTE]
> Block-level Markdown elements like lists won't be converted into HTML.
Callout headings avoid clashing with other content heading by being styled as paragraphs. However, callout headings do have IDs for easy fragment references.

For troubleshooting callouts ("orange"), use the 🚧 emoji:

```
> 🚧 A troubleshooting callout title
> Callout content can have `code` or _emphasis_ and other inline elements in it, [including links](#).
> Every line break after the first becomes a new paragraph inside the callout.
```

While no longer used in the Buildkite Docs, Work-in-progress (WIP) or Experimental callouts ("orange"), use the 🛠 emoji:

```
> 🛠 This marks it as WIP
> Callout content can have <code>code</code> or <em>emphasis</em> and other inline elements in it, <a href="#">including links</a>.
> Every line break after the first becomes a new paragraph inside the callout.
```

Any other emoji will render blockquotes as normal.

#### Callouts within lists

If you need to make a callout as part of a bulleted or numbered list item, the callout options above will not work. Therefore, add the callout as an indented (by 4 spaces) block level text preceded with the type of callout in bold text, such as `**Note:**`. For example:

````
1. Do this...

    **Note:** This only works under certain circumstances.

1. Do this next...
````

which generates

1. Do this...

    **Note:** This only works under certain circumstances.

1. Do this next...

### Tables

#### Two-column tables

To use a custom style for two-column tables that are rendered like the table in the [Job states](/docs/pipelines/defining-steps#job-states) section, use the following syntax:

```
Column header 1   | Column header 2
----------------- | ----------------
Line 1, column 1  | Line 1, column 2
Line 2, column 1  | Line 2, column 2
Line 3, column 1  | Line 3, column 2
{: class="two-column"}
```

The `{: class="two-column"}` class added at the end of a two-column table is what allows the custom table style to work.

#### Fixed-width tables

To use a custom style for two column tables that include long text without whitespace that are rendered like the table in the [Webhooks HTTP headers](/docs/apis/webhooks#http-headers) section, use the following syntax:

```
Column header 1   | Column header 2
----------------- | ----------------
Line 1, column 1  | Line 1, column 2
Line 2, column 1  | Line 2, column 2
Line 3, column 1  | Line 3, column 2
{: class="fixed-width"}
```

#### Responsive tables

Append `{: class="responsive-table"}` to any table to render it with responsive behavior. Use the following syntax:

```
Column header 1   | Column header 2
----------------- | ----------------
Line 1, column 1  | Line 1, column 2
Line 2, column 1  | Line 2, column 2
Line 3, column 1  | Line 3, column 2
{: class="responsive-table"}
```

This also works if you apply the CSS class to pure html tables, for example:

```html
<table class="responsive-table">
  <thead>
    <tr>
      <th>Column header 1</th>
      <th>Column header 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Line 1, column 1</td>
      <td>Line 1, column 2</td>
    </tr>
    <tr>
      <td>Line 2, column 1</td>
      <td>Line 2, column 2</td>
    </tr>
  </tbody>
</table>
```

This is useful for improving readability on small screens. Otherwise, complex tables or tables with very long variable names can be difficult to read or break the page layout.

On small screens, responsive tables are styled as stacked lists, and table headings are duplicated against the respective table cells of data. On medium-sized and large screens, these duplicated _faux_ table headings are hidden and the tables look as per usual.

### Code and filenames

This section deals with adding and properly formatting code in the documentation, as well as naming files, pages, and their derivative URLs.

#### Code formatting

The Buildkite docs uses the GitHub flavor of Markdown for [formatting code](https://help.github.com/articles/basic-writing-and-formatting-syntax/#quoting-code).

For code or filenames as a part of a sentence, use a backtick "\`\" before and after the words that need to be marked as code. For example:

```md
Each command step can run either a shell command like `npm install`, or an executable file or script like `build.sh`.
```

> [!NOTE]
> Do not use code fragments in page headings or section headings.

#### Code blocks

A code example longer than a couple of words that isn’t part of a sentence/a multi-line code sample needs to be formatted as a code block according to the [GitHub Markdown flavor](https://help.github.com/articles/basic-writing-and-formatting-syntax/#quoting-code).
To add a code block, use three (3) backticks (\`\`\`) before and after the code block, for example:

````
```
Hello, world!
```
````

generates

```
Hello, world!
```

To add a filename to a codeblock, immediately after the block use `{: codeblock-file="filename.extension"}` (for example, `{: codeblock-file="pipeline.yml"}`).

To add syntax highlighting, you can use [Rouge](http://rouge.jneen.net/), for example:

````
```bash
#!/bin/sh
echo "Hello world"
```
````

generates

```bash
#!/bin/sh
echo "Hello world"
```

You can see the full list of supported languages and lexers [here](https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers)

This probably goes without saying, but do not use code fragments in page headings or section headings.

#### Escaping emoji in code snippets

An emoji code will be rendered as emoji in the docs. For example, `":hammer: Tests"` will be rendered as `"🔨 Tests"`.

If you need to provide an example code snippet that contains emoji code and you don't won't the emoji to be rendered as emoji in the example snippet, you need to use emoji escaping by putting a `\` before `:` characters. To keep `":hammer: Tests"` looking as `":hammer: Tests"`, use: `"\:hammer\: Tests"`.

Another example:

````
```yml
steps:
  - group: "\:lock_with_ink_pen\: Security Audits"
    key: "audits"
    steps:
      - label: "\:brakeman\: Brakeman"
        command: ".buildkite/steps/brakeman"
```
````

Will be rendered as:

```yml
steps:
  - group: ":lock_with_ink_pen: Security Audits"
    key: "audits"
    steps:
      - label: ":brakeman: Brakeman"
        command: ".buildkite/steps/brakeman"
```

Here it is also necessary to use emoji escaping as the documentation website considers custom emojis and expressions surrounded by colons in code snippets to be images and will try to render them into png image links within the code snippets. For example,`:aws:` will be rendered as: `"<img class="emoji" title="aws" src="https://buildkiteassets.com/emojis/img-buildkite-64/aws.png" draggable="false"/>`.

Use escaping to prevent this.

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

`<%= render_markdown 'step_2_3_github_custom_status' %>`

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

### Updating vendor\emojis

From time to time, you will start seeing an update to `vendor\emojis` submodule as a default initial file change in every new branch you create. This happens because these new branches will have an older version of the emoji submodule than the main branch.

**Do not commit the `vendor\emojis` commit!** Instead, run `git submodule update`. This will take care of the emoji commit - until your local emoji submodule version falls behind again. Then you will need to run `git submodule update` for your local Docs repository again.

If you do accidentally commit the `vendor\emojis` update, use `git reset --soft HEAD~1` to undo your last commit, un-stage the erroneous submodule change, and commit again.

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

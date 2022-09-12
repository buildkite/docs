# Style Guide

Welcome to the Buildkite styleguide. These are the guidelines we use to write the docs.
If something isn't included in this guide, see the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/).

Table of contents:
* [Language](#Language)
* [Style and formatting](#Style-and-formatting)
* [Code and filenames](#Code-and-filenames)
* [Working with the docs site](#Working-with-the-docs-site)
* [Screenshots](#Screenshots)
* [GraphQL API schema](#graphql-api-schema)

## Language
This section covers everything related to the language and formatting used in Buildkite documentation (and website, to some extent).

### Dictionary
We use American English, so our first-call dictionary is [Merriam Webster](https://www.merriam-webster.com/). It is not a single source of truth, just a good starting/reference point.
We also use [Vale](https://github.com/apps/vale-linter), our own [linter](https://github.com/buildkite/docs#linting) with a file that contains our own [custom list of words](https://github.com/buildkite/docs/blob/main/vale/vocab.txt) that may confuse the spellchecker, [filename linter](https://ls-lint.org/1.x/getting-started/introduction.html), and a [markdown linter](https://github.com/DavidAnson/markdownlint).

### English flavor
Again, we use American English. We're also a highly multi-national team, so here is the list of the most notable [differences between American, British, and Australian English](http://web.archive.org/web/20180925084522/http://www.linktranslation.com.au/the-differences-between-american-british-and-australian-english/) English to watch out for.

### Commas
Keep it clean and uncluttered. If the sentence can live without that comma - leave it out.

### Serial commas
Absolutely yes, yes, and yes.

### Active/passive voice

Generally, use active voice. It's usually clearer and simpler.

### Gender
Always use ‘they’, never use ‘he’ or ‘she’.
More info on writing about pronouns and in the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/grammar/nouns-pronouns).

### Talking about YAML

YAML looks more simple than it is.
It takes some care and discipline to write about.
See [Talking about YAML](./yaml.md) for complete guidance.

## Style and formatting
This section covers the matters that go beyond language and provides guidelines for consistency and a unified look.

### Consistency
Keep your writing consistent with itself and other docs. This means abbreviations, capitalization, hyphens, names of UI elements, etc.

### Title capitalization
Use Title case in H1 page headings `# Heading`:
*"The Quick Brown Fox Jumps Over the Lazy Dog."*
Also known as headline style and capital case. All words capitalized, except for certain subsets defined by rules that are not universally standardized, often minor words such as "the" (as above), "of", or "and". The standardization is only at the level of house styles and individual style manuals. (See Headings and publication titles.) A simplified variant is start case, where all words, including articles, prepositions, and conjunctions, start with a capital letter.

Use Sentence case in section headings (`## Heading`,`### Heading`, `#### Heading`, etc.):
*"The quick brown fox jumps over the lazy dog."*
The standard case used in English prose. Generally equivalent to the baseline universal standard of formal English orthography mentioned above; that is, only the first word is capitalized, except for proper nouns and other words which are generally capitalized by a more specific rule.

When in doubt, consult [Title.sh](https://title.sh/) for proper capitalization according to the The Chicago Manual of Style.

More info [on Wikipedia](https://en.wikipedia.org/wiki/Capitalization#By_name_of_style).

### Capital letters in proper names
Only capitalize the name of the product - for example, 'GitHub organization' and not 'GitHub Organization'.

### Capital letters in UX elements
Use title capitalization for names of tabs and buttons in the Buildkite interface - for example, 'Personal Settings', 'Repository Providers', 'Save Organization Settings'.

### Lists (bullet lists and numbered steps)
Capitalize the first word; no full stops at the end if it's not a full sentence. If it's a full sentence, give it a full stop.

See also what Microsoft has to say on [lists](https://docs.microsoft.com/en-us/style-guide/scannable-content/lists).

### Writing numbers
Write out numbers up to 10, then use digits - '58 bugs in this script and just two hours to fix them all!'
Long numbers use commas to separate thousands - '100,000,000.00'. When in doubt, look [here](https://docs.microsoft.com/en-us/style-guide/numbers).

Do not use numbers in page headings. Only use numbers less than 10 in section headings.
No restrictions on using numbers in the body of the text.


### Referring to UI elements
UI elements should be italic. For example:

To get your agent token, navigate to *Agents*, then select *Reveal Agent Token*.


### Time and date

Use 24hr time with hours and minutes, but not seconds. Include timezone. For example, 17:00 AEST

More in [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/term-collections/date-time-terms).

### Spacing after full stops
**Question:** Should you use one or two spaces after end punctuation?
**Answer:** One space.

A little [historical background](https://www.onlinegrammar.com.au/the-grammar-factor-spacing-after-end-punctuation-capitals/) on why this is even a valid question.
P.S. Remember that, ironically enough, in Markdown, line breaks demand exactly two blank spaces at the end of the line.

### Platform differences
|                      | Docs                                                      | Twitter and Blog                                                        | Changelog                                                               |
|----------------------|-----------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|
| We (as in Buildkite) | No                                                        | Yes                                                                     | Avoid if possible; use 'I' if you need to                               |
| Links                | Relative paths to other docs, full paths to anything else | Always full paths, check for HTTPS and that you’re not using .localhost | Always full paths, check for HTTPS and that you’re not using .localhost |
| Exclamation marks    | No                                                        | Yes, although use with restraint, and not more than one in a row        | Yes, although use with restraint, and not more than one in a row        |


### Glossary of notable terms and their spelling
| Word                      | Usage                                                                                            |
|---------------------------|--------------------------------------------------------------------------------------------------|
| The Buildkite Agent/agent | When referring to the running process/piece of software as a whole                               |
| `buildkite-agent`         | When referring to the CLI tool, visually should be presented in a code block                     |
| Sign up/log in            | The action of signing up                                                                         |
| Signup/login              | When referring to a page that enables signing up or to the signup process                        |
| Time out/timeout          | Time out is a verb, timeout is a noun                                                            |
| API, SSO, SAML            | Always capitalized                                                                               |
| GitHub                    | Always capitalized, with an uppercase H in the middle                                            |
| Two-factor authentication | In a sentence two-factor authentication, in a title Two-Factor Authentication, in short form 2FA |
| Single sign-on            | In a sentence single sign-on, in a title Single Sign-On, in short form SSO                       |

### Common trip-ups
Linters cannot do all of the work for you, so please pay attention to the following cases:

* **Their/they’re/there, your/you’re** - [check](https://www.dictionary.com/e/their-there-theyre/ ) if you’ve got the right one for your situation!
* **Affect/effect** - affect is a verb, effect is a noun. When you affect something, you’re impacting or changing the thing. When you have an effect, it’s the outcome or result of a change.
* Be mindful of **hyphens**! Hyphens for compound adjectives, no hyphens in verbs: 'end-user documentation' vs. 'for the end user'.

### Headings
No multi-sentence headings or full stops at the end of a sentence in page or sentence headings.
Be consistent about heading levels - H1, H2, H3 - no jumping from H1 to H3 or H2 to H4.

## Code and filenames
This section deals with adding and properly formatting code in the documentation + naming files, pages, and their derivative URLs.

### Code formatting
We use the GitHub flavor of markdown for [formatting code](https://help.github.com/articles/basic-writing-and-formatting-syntax/#quoting-code).

For code or file names as a part of a sentence, use "\`\" before and after the word(s) that need(s) to be marked as code: Each command step can run either a shell command like `npm install`, or an executable file or script like `build.sh`.
In markdown this sentence looks like this: " Each command step can run either a shell command like \`npm install\`, or an executable file or script like \`build.sh\`. "

Do not use code fragments in page headings or section headings.

### Code blocks
A code example longer than a couple of words that isn’t part of a sentence/a multi-line code sample needs to be formatted as a code block according to the [GitHub markdown flavor](https://help.github.com/articles/basic-writing-and-formatting-syntax/#quoting-code).
To add a code block, indent it using four (4) spaces or use 3 backticks (\`\`\`) before and after the code block.

```
Hello, world!
```

To add a filename to a codeblock, immediately after the block use `{: codeblock-file="filename.extension"}` (for example, `{: codeblock-file="pipeline.yml"}`).

To add syntax highlighting, you can use [Rouge](http://rouge.jneen.net/), for example:
```
```bash
#!/bin/sh
echo "Hello world"```
```
turns into
```bash
#!/bin/sh
echo "Hello world"
```
You can see the full list of supported languages and lexers [here](https://github.com/rouge-ruby/rouge/wiki/List-of-supported-languages-and-lexers)

This probably goes without saying, but do not use code fragments in page headings or section headings.

### Escaping emoji in code snippets

An emoji code will be rendered as emoji in the docs. For example, `":hammer: Tests"` will be rendered as `"🔨 Tests"`.

If you need to provide an example code snippet that contains emoji code and you don't won't the emoji to be rendered as emoji in the example snippet, you need to use emoji escaping by putting a `\` before `:` characters. To keep `":hammer: Tests"` looking as `":hammer: Tests"`, use: `"\:hammer\: Tests"`.

Another example:

```
steps:
  - group: "\:lock_with_ink_pen\: Security Audits"
    key: "audits"
    steps:
      - label: "\:brakeman\: Brakeman"
        command: ".buildkite/steps/brakeman"
```

Will be rendered as:

```yml
steps:
  - group: ":lock_with_ink_pen: Security Audits"
    key: "audits"
    steps:
      - label: ":brakeman: Brakeman"
        command: ".buildkite/steps/brakeman"
```

Here it is also necessary to use emoji escaping as the documentation website considers custom emojis and expressions surrounded by colons in code snippets to be images and will try to render them into png image links within the code snippets. For eample,`:aws:` will be rendered as: `"<img class="emoji" title="aws" src="https://buildkiteassets.com/emojis/img-buildkite-64/aws.png" draggable="false"/>`.

Use escaping to prevent this.

## Working with the docs site
Our docs website is a custom build. This section gives some guidance on working with the setup.

### Markdown

The docs website uses the [Redcarpet](https://github.com/vmg/redcarpet) Ruby library for Markdown.
Redcarpet does not conform with the CommonMark or GitHub Flavored Markdown specifications.
Watch out for differences such as:

- Inline HTML comments are escaped and will appear in the output, but block comments won't.

  ```markdown
  ## Hello world! <!-- this comment is visible to readers -->

  <!-- This comment is hidden -->
  ```

- Four spaces are required for list continuation paragraphs.

  **✅ Do this**
  ```markdown
  1. First paragraph of this list item.

      A happy second paragraph, indented four spaces.
  ```

  **❌ Don't do this**
  ```markdown
  2. First paragraph of this list item.

     A sad, broken second paragraph, indented three spaces.
  ```

### Adding and naming new documentation pages
To add a new documentation page, create it as a *.md.erb file. Give it a lowercase name, separate words using underscores.
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

> **Note:** Ruby, which keeps the website running, interprets underscores in filenames as hyphens. So if a page is called `octopussy_cat.erb.md`, you need to add it as `octopussy-cat` to the `nav.yml` file.

### Filenames and filename linting
Use `snake_case` for `*.md.erb` files in `pages`. The [`.ls-lint` linter](https://github.com/buildkite/docs/blob/main/.ls-lint.yml) checks if this rule is observed.
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
A [markdown linter](https://github.com/DavidAnson/markdownlint) is at work in Buildkite documentation.

The enabled markdown linting rules are in [`.markdownlint.yaml`](https://github.com/buildkite/docs/blob/main/.markdownlint.yaml) file.


### Links
Use standard markdown links syntax for both internal and external links.

Internal links need to start with `/docs`, for example:

```
Read more about [environment variables](/docs/pipelines/environment-variables)
```

### Anchor links
To use an anchor link where you need to link to an H2-level heading, append the section's name to the main page link, for example:
`/docs/pipelines/secrets` will contain `/docs/pipelines/secrets#using-a-secrets-storage-service`.

If you need to create a link to an H3-level heading, start with an H2-level anchor link. Such links are generated automatically from the section title, and are viewable in the # that appears when you mouse over the heading. Add a `-` to the H2-level anchor link, and append the full name of the H3-level title to it. The result will be a long link. For example:

`/docs/pipelines/environment-variables#environment-variable-precedence-job-environment`

Here the H2-level link for "\#\# Environment variable precedence" is `/docs/pipelines/environment-variables#environment-variable-precedence` and the H3-level link for "\#\#\# Job environment"is appended as `-job-environment`.

### Content reuse (snippets)
You can use snippets to reuse the same fragment in several documentation pages (single sourcing). This way, you can update the snippet once, and the changes will be visible on all pages that use this snippet.

Add snippet files to the directory where they'll be used, prefaced with an underscore in the file name. For example `_my_snippet.md.erb`. **However**, when pulling the snippet into a file, remove the leading underscore.

This way, this:

`/integrations/_step_2_3_github_custom_status.md.erb`

Needs to become this in a snippet render link:

`<%= render_markdown 'integrations/step_2_3_github_custom_status' %>`

Put the snippet render link where you need to add the content of the snippet.

Do not use H2, H3-level headings in the first line of a snippet because this results in generation of incorrect anchor links for such headings. Instead, if you need to start a snippet with a heading, add the heading to the main document just before you add a snippet render link.

If a snippet is stored within a sub-solder, you need to specify the names of both folder and subfolder in the link to the snippet.

So a link to `_agent_events_table.md.erb` stored within `webhooks` sub-folder in `apis` folder will need to look like this:

`<%= render_markdown partial: 'integrations/step_2_3_github_custom_status' %>`

### Custom elements
We have a few custom scripts for adding useful elements that are missing in Markdown.
To save yourself a few unnecessary rounds of edits in the future, remember that if you see a fragment written in HTML, links within such fragment should also follow the HTML syntax and not markdown (more on this in [Note blocks](#note-blocks)).

#### Beta flags
To mark a content page in the site as being in beta, add its relative path *after* `docs` to the `app/models/beta_pages.rb` file.

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
To generate a table of contents from all your \##\-level headings, use `{:toc}`.
Make sure there are no spaces after the `{:toc}` - spaces immediately after this custom element are known to break the script.

To omit a table of contents, use `{:notoc}`.
Typically `{:notoc}` is for pages where the text immediately following the \#-level heading is the body of the page or where there's only one \##\-level heading, which looks lonely in a table of contents.

A page must have either `{:toc}` or `{:notoc}`.

#### Note blocks
Currently, the following syntax is commonly used for adding note blocks to the documentation:

Regular info ("green") note:

```
<section class="Docs__note">
  <h3>Setting agent defaults</h3>
  <p>Use a top-level <code>agents</code> block to <a href="/docs/pipelines/defining-steps#step-defaults">set defaults</a> for all steps in a pipeline.</p>
</section>
```
or

```
<div class="Docs__note">
  <h3>Line endings</h3>
  <p>A text field normalizes line endings to Unix format (<code>\n</code>).</p>
</div>
```
Note that 'note' blocks are written in HTML so markdown syntax will not work. Use HTML syntax for links and formatting within 'note' blocks.


For troubleshooting note blocks ("orange" notes), use the following example syntax:

```
<section class="Docs__troubleshooting-note">
  <p>When a <a href="/docs/pipelines/trigger-step">triggered build</a> fails, the step that triggered it will be stuck in the <code>running</code> state forever.</p>
</section>
```
For troubleshooting note blocks ("orange" notes) with ⚠️ ("warnings"), use the following example syntax:

```
<div class="Docs__troubleshooting-note">
  <h3>Fast transitions and webhooks</h3>
    <p>Note that if a builds transitions between states very quickly, for example from blocked (<code>finished</code>) to unblocked (<code>running</code>), the webhook may be in a different state from the actual build. This is a known limitation of webhooks, in that they may represent a later version of the object than the one that triggered the event.</p>
</div>
```

Note that these note and troubleshooting note blocks are written in HTML so markdown syntax will not work. Use HTML syntax for links and formatting within 'troubleshooting note' blocks.

It is recommended to keep the headings in notes level-independent because a note within a H3-level section will require a H4-level heading and it's easy to forget about this, especially when moving a large section of documentation to a different page.

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
Append `{: class="responsive-table"}` to any table to render it with responsive behaviour. Use the following syntax:

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

#### Prepending icons
You can prepend an icon to boost the visual emphasis for an inline text. To do this, wrap the text with `<span class="add-icon-#{ICON_NAME}">`.

At the time of writing, there are only three icons available — agent, repository, and plugin. To add more icons see `$icons` in `_add-icon.scss`, add a new name as the key and the inline SVG. Icon dimension must be 22px * 22px.

Please note: unlike emojis, these icons are generic and contextual, and they are used as to help readers to better visually differentiate specific terms from the rest of the text.

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
3. Compose relevant alt text for the image file using Title case
4. Add your image file to the documentation page using the following code example `<%= image "your-image.png", width: 1110, height: 1110, alt: "Screenshot of Important Feature" %>`.
For large images/screenshots taken on a retina screen, use `<%= image "your-image.png", width: 1110/2, height: 1110/2, alt: "Screenshot of Important Feature" %>`.

## GraphQL API schemas

There are over 300 GraphQL API schema pages and they are manually generated with a shell script.
When there are changes to the API, we can update them with these steps:

1. Starting from the [`buildkite/buildkite`](https://github.com/buildkite/buildkite) repo, pull the latest changes into the `main` branch
2. Build the schema by running `rails api:graph:export`. The latest schema can be found in `frontend/app/graph/schema.json`
3. Go back to [`buildkite/docs`](https://github.com/buildkite/docs) and replace `data/graphql_data_schema.json`'s content with the latest schema
4. Run the script `./scripts/generate-graphql-api-content.sh`. This will generate and update all the schema pages under `pages/apis/graphql/schemas/`
5. Stage and commit these changes

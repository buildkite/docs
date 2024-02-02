# Writing style guide

Welcome to the Buildkite writing style guide.

These guidelines provide details about the language and words used to write the Buildkite docs, as well as details about its writing style and format.
If something isn't included in this guide, see the [Google developer documentation style guide](https://developers.google.com/style), followed by the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/).

For details about the Markdown syntax used to render your writing as well as the Buildkite docs' file structure, as well as details on working with the site, and using screenshots, refer to the [Markdown syntax style guide](markdown-syntax-style.md).

Table of contents (main headings):
* [Language](#language)
* [Style and formatting](#style-and-formatting)

## Language

This section covers everything related to the language, words, and formatting used in Buildkite documentation (including the website, to some extent).

### English flavor

Use US English. As a highly multi-national team, here is the list of the most notable differences between [Australian, American (US), and British English](https://blog.e2language.com/australian-english-vs-american-english-vs-british-english/) English to watch out for.

### Dictionary

Buildkite's first-call dictionary is [Merriam Webster](https://www.merriam-webster.com/) for US English. This is not a single source of truth, just a good starting/reference point.

> [!NOTE]
> The Buildkite docs build process uses [Vale](https://github.com/apps/vale-linter), a [linter](/README.md#linting) with a file that contains a [custom list of words](/vale/styles/vocab.txt) that may confuse the spellchecker, [filename linter](https://ls-lint.org/1.x/getting-started/introduction.html), and a [Markdown linter](https://github.com/DavidAnson/markdownlint).

### Commas

Keep it clean and uncluttered. If the sentence can live without that comma - leave it out.

### Serial commas

Absolutely yes, yes, and yes. Use serial commas _when required_ - typically when listing items in a sentence.

Serial commas are also known as 'Oxford commas'.

**Why?** Note the difference between these two sentences:

1. _I went to the shop with my parents, Fred and Wilma._
1. _I went to the shop with my parents, Fred, and Wilma._

How many people are being referred to in each of these sentences?

* In sentence 1, in addition to me, there are two more people involved: Fred and Wilma, both of whom happen to be my parents.
* In sentence 2, in addition to me, there are four more people involved: my parents (whose names are not mentioned), as well as Fred, and Wilma.

Therefore, use serial commas to distinguish individual items in a list from those which are not.

### Active/passive voice

Whenever possible, use active voice, which is generally clearer and simpler.

Conventional/natural English sentence word order is subject > verb > object, where the subject or object could be clauses in their own right.

_Active voice_ typically follows this natural word order and is generally easier for readers to follow. More specifically, with active voice, the subject comes before the main verb/action in a sentence.\
For example:
* _The XYZ window_ (subject) _displays_ (verb) _the result._ (object)\
That is:\
_The XYZ window displays the result._
* _Select "Settings" > "YAML Migration"_ (subject clause) _to open_ (action) _the YAML migration settings._ (object)\
That is:\
_Select "Settings" > "YAML Migration" to open the YAML migration settings._

Passive voice is when the object of a sentence comes before its (main) verb/action.\
Following on from the examples above (written in passive voice):
* _The result_ (object) _is displayed_ (verb) _by the XYZ window._ (subject clause)\
That is:\
_The result is displayed by the XYZ window._
* _The YAML migration settings_ (object) _is opened_ (action) _by selecting "Settings" > "YAML Migration"._ (subject clause)\
That is:\
_The YAML migration settings is opened by selecting "Settings" > "YAML Migration"._\
You could make this sentence sound a little more like it's in the active voice through a little rearrangement:\
_Open the YAML migration settings by selecting "Settings" > "YAML Migration"._\
However, the fully active voice version (above) is preferable for instructional step-by-step content like this.

Aim to use active voice in instructional step-by-step content and avoid passive voice.\
Passive voice is useful when you want to emphasize the object, for example when describing the consequence of an activity in the previous sentence. However, stick to active voice for such sentences unless the object requires emphasis.

> [!TIP]
> While identifying active/passive voice usage can sometimes be tricky, as a general principle, if you find yourself writing "by _verb/action word_" within a lot of your sentences, try flipping the subject and object parts of these sentences around when re-writing them.

### Gender

Always use ‘they’, never use ‘he’ or ‘she’.
More info on writing about pronouns and in both the [Google developer documentation style guide](https://developers.google.com/style/pronouns#gender-neutral-pronouns) and [Microsoft Style Guide](https://learn.microsoft.com/en-us/style-guide/grammar/nouns-pronouns#pronouns-and-gender) on pronouns.

## Style and formatting

This section covers the matters that go beyond language and provides guidelines for consistency in writing with a unified look.

### Consistency

Keep your writing consistent with itself and other docs. This means abbreviations, capitalization, hyphens, names of UI elements, etc.

### Headings

Use sentence case in all headings:

_"The quick brown fox jumps over the lazy dog."_

The standard case used in English prose. That is, only the first word is capitalized, except for proper nouns and other words which are generally capitalized by a more specific rule.

Do not create multi-sentence headings, or add full stops/periods or other punctuation at the end of a heading.

Refer to [Headings in the Markdown syntax guide](markdown-syntax-style.md#headings) for details on how to implement headings in Markdown.

### Product Names (and product features)

Only use Title Case (initial capital letters) for the name of the product (product names), and match capital letter usage in product names as an organization would use them in these products - for example:

* 'Docker Compose overview' and not 'Docker Compose Overview' 
* 'GitHub organization' and not 'GitHub Organization'

> [!NOTE]
> Avoid using Title Case for product features, that is, when mentioning or describing them in documentation.

### UI elements

UI elements should be formatted in italics. For example:

To get your agent token, navigate to _Agents_, then select _Reveal Agent Token_.

> [!NOTE]
> Match the capitalization used in the Buildkite interface, even if title (or any other) case has been used for product features.

Refer to [UI elements in the Markdown syntax guide](markdown-syntax-style.md#ui-elements) for details on how to write and present UI elements in the Buildkite docs.

### Lists (bullet lists and numbered steps)

Capitalize the first word; no full stops at the end if it's not a full sentence. If it's a full sentence, give it a full stop.

See also what [Google](https://developers.google.com/style/lists#capitalization-and-end-punctuation) and [Microsoft](https://learn.microsoft.com/en-us/style-guide/scannable-content/lists#punctuation) say about lists.

### Writing numbers

Write out numbers up to 10, then use digits - '58 bugs in this script and just two hours to fix them all!'
Long numbers use commas to separate thousands - '100,000,000.00'. When in doubt, see what [Google](https://developers.google.com/style/numbers) and [Microsoft](https://docs.microsoft.com/en-us/style-guide/numbers) say about numbers.

Avoid using numbers in page headings. Only use numbers less than 10 in section headings.
No restrictions on using numbers in the body of the text.

### Time and date

Use 24hr time with hours and minutes, but not seconds. Include timezone. For example, 17:00 AEST

More about this in the [Google developer documentation style guide](https://developers.google.com/style/dates-times).

### Spacing after full stops

Refer to [Spacing after full stops in the Markdown syntax guide](markdown-syntax-style.md#spacing-after-full-stops) for more details about this.

### Platform differences

This table summarizes writing style differences across different platforms, distinguishing them from the Buildkite 'Docs'.

|                      | Docs                                                      | Twitter and Blog                                                        | Changelog                                                               |
|----------------------|-----------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|
| We (as in Buildkite) | No                                                        | Yes                                                                     | Avoid if possible; use 'I' if you need to                               |
| Exclamation marks    | No                                                        | Yes, although use with restraint, and not more than one in a row        | Yes, although use with restraint, and not more than one in a row        |

### Glossary of notable terms and their spelling

| Word                      | Usage                                                                                            |
|---------------------------|--------------------------------------------------------------------------------------------------|
| The Buildkite Agent/agent | When referring to the running process/piece of software as a whole                               |
| `buildkite-agent`         | When referring to the CLI tool, visually should be presented in a code block                     |
| Sign up/log in            | The action of signing up (that is, the verb form of these terms)                                                                         |
| Signup/login              | When referring to a page that enables signing up or to the signup process (that is, the adjective or noun form of these terms)                       |
| Time out/timeout          | Time out is a verb, timeout is a noun or adjective                                                            |
| API, SSO, SAML            | Always capitalized                                                                               |
| GitHub                    | Always capitalized, with an uppercase H in the middle                                            |
| Two-factor authentication | In short form 2FA |
| Single sign-on            | In short form SSO                       |

### Common trip-ups

Linters cannot do all of the work for you, so please pay attention to the following cases:

* **Their/they’re/there, your/you’re** - [check](https://www.dictionary.com/e/their-there-theyre/ ) if you’ve got the right one for your situation!
* **Affect/effect** - affect is a verb, effect is a noun. When you affect something, you’re impacting or changing the thing. When you have an effect, it’s the outcome or result of a change.
* Be mindful of **hyphens**! Hyphens for compound adjectives, no hyphens in verbs: 'end-user documentation' vs. 'for the end user'.

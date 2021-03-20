# Styleguide  
Welcome to the Buildkite styleguide. These are the guidelines we use to write the docs. 
If something isn't included in this guide, see the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/welcome/). 

Table of contents:
* [Language](#Language)
* [Style and formatting](#Style-and-formatting)  
* [Code and filenames](#Code-and-filenames)
* [Screenshots](#Screenshots)

## Language  
This section covers everything related to the language and formatting used in Buildkite documentation (and website, to some extent).

### Dictionary  
We use American English, so our first-call dictionary is [Merriam Webster](https://www.merriam-webster.com/). It is not a single source of truth, just a good starting/reference point.  
We also use [Vale](https://github.com/apps/vale-linter) and our own [linter](https://github.com/buildkite/docs#linting) with a file that contains our own [custom list of words](https://github.com/buildkite/docs/blob/master/vale/vocab.txt) that may confuse the spellchecker.

### English flavor 
Again, we use American English. We're also a highly multi-national team, so here is the list of the most notable [differences between American, British, and Australian English](http://linktranslation.com.au/the-differences-between-american-british-and-australian-english/) Eglish to watch out for.  

### Commas  
Keep it clean and uncluttered. If the sentence can live without that comma - leave it out.

### Serial commas
Absolutely yes, yes, and yes.  

### Active/passive voice    
Generally, use passive voice. It gives a bit more distance from what we're talking about, even if it is a bit longer. There are certainly times for active voice, but it's too nuanced for this guide! [Look here](https://www.aje.com/en/arc/writing-with-active-or-passive-voice/) for some guidance.

### Gender 
Always use ‘they’, never use ‘he’ or ‘she’. 
More info on writing about pronouns and in the [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/grammar/nouns-pronouns). 

## Style and formatting 
This section covers the matters that go beyond language and provides guidelines for consistency and a unified look.  

### Consistency
Keep your writing consistent with itself and other docs. This means abbreviations, capitalization, hyphens, names of UI elements, etc.   

### Title capitalisation  

Use Title case in page headings:
*"The Quick Brown Fox Jumps Over the Lazy Dog."*  
Also known as headline style and capital case. All words capitalized, except for certain subsets defined by rules that are not universally standardized, often minor words such as "the" (as above), "of", or "and". The standardization is only at the level of house styles and individual style manuals. (See Headings and publication titles.) A simplified variant is start case, where all words, including articles, prepositions, and conjunctions, start with a capital letter.

Use Sentence case in section headings: 
*"The quick brown fox jumps over the lazy dog."*  
The standard case used in English prose. Generally equivalent to the baseline universal standard of formal English orthography mentioned above; that is, only the first word is capitalized, except for proper nouns and other words which are generally capitalized by a more specific rule.

More info [on Wikipedia](https://en.wikipedia.org/wiki/Capitalization#By_name_of_style).

### Capital letters in proper names 
Only capitalize the name of the product - e.g. 'GitHub organization' and not 'GitHub Organization'.  

### Capital letters in UX elements
Use title capitalization for names of tabs and buttons in the Buildkite interface - e.g. 'Personal Settings', 'Repository Providers', 'Save Organization Settings'.

### Bullet lists  

Capitalize the first word; no full stops at the end if it’s only one sentence. If there are two or more sentences in the list element, the final one will have a full stop.  

See also what Microsoft has to say on [lists](https://docs.microsoft.com/en-us/style-guide/scannable-content/lists). 

### Writing numbers  
Write out numbers up to 10, then use digits - '58 bugs in this script and just two hours to fix them all!'
Long numbers use commas to separate thousands - '100,000,000.00'. When in doubt, look [here](https://docs.microsoft.com/en-us/style-guide/numbers).  

Do not use numbers in page headings. Only use numbers less than 10 in section headings.  
No restrictions on using numbers in the body of the text.  

### Time and date  
Use 24hr time with hours and minutes, but not seconds. Include timezone. e.g. 17:00 AEST 
More in [Microsoft Style Guide](https://docs.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/term-collections/date-time-terms).

### Spacing after full stops  
**Question:** Should you use one or two spaces after end punctuation?
**Answer:** One space.

A little [historical background](https://www.onlinegrammar.com.au/the-grammar-factor-spacing-after-end-punctuation-capitals/) on why this is even a valid question.
P.S. Remember that, ironically enough, in Markdown, line breaks demand exactly two blank spaces at the end of the line.  

### Platform differences  
|                      | Docs                                                      | Twitter                                                                 | Blog                                                                    | Changelog                                                               |
|----------------------|-----------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------------------------------------|
| We (as in Buildkite) | No                                                        | Yes                                                                     | Yes                                                                     | Avoid if possible; use 'I' if you need to                                 |
| Links                | Relative paths to other docs, full paths to anything else | Always full paths, check for HTTPS and that you’re not using .localhost | Always full paths, check for HTTPS and that you’re not using .localhost | Always full paths, check for HTTPS and that you’re not using .localhost |
| Exclamation marks    | No                                                        | Yes, although use with restraint, and not more than one in a row        | Yes, although use with restraint, and not more than one in a row        | Yes, although use with restraint, and not more than one in a row        |


### Glossary of notable terms and their spelling   
| Word                      | Usage                                                                                            |
|---------------------------|--------------------------------------------------------------------------------------------------|
| The Buildkite Agent/agent | When referring to the running process/piece of software as a whole                               |
| buildkite-agent           | When referring to the cli tool, visually should be presented in a code block                     |
| Sign up/log in            | The action of signing up                                                                         |
| Signup/login              | When referring to a page that enables signing up or to the signup process                        |
| API, SSO, SAML            | Always capitalized |
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
We use the basic GitHub flavor of markdown for [formatting code](https://help.github.com/articles/basic-writing-and-formatting-syntax/#quoting-code). 

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


### Adding and naming new documentation pages  
To add a new documentation page, create it as a *.md.erb file. Give it a lowercase name, separate words using underscores.
To add the new page to the documentation sidebar on https://buildkite.com/docs, add the corresponding entry to 
`app/views/layouts/application.html.erb` with a description (e.g. `"G Cloud Identity", 'integrations/sso/g-cloud-identity'` ).
> **Note:** Ruby, which keeps the website running, interprets underscores in filenames as hyphens. So if a page is called `octopussy_cat.erb.md`, you need to add it as `octopussy-cat` to the `application.html.erb` file.     

### Escaping vale linting  

If you absolutely need to add some word that triggers the linter, you can use escaping via the following syntax: 

```
<!-- vale off -->

This is some text

more text here...

<!-- vale on -->
```
Use the `vale on` syntax before a phrase that needs to be bypassed by the linter and don't forget to turn it on again with `vale on`.  

### Custom elements  
We have a few custom scripts for adding useful custom elements that are missing in vanilla Markdown.  

#### Table of contents  
To generate a table of contents from all your \##\-level headings, use `{:toc}`. 
>Note: Make sure there are no spaces after the `{:toc}` - spaces immediately after this custom element are known to break the script.  

#### Docs Note  

Use the following example to add a 'note' in the documentation.  
 
```
<section class="Docs__note">
  <h3>Setting agent defaults</h3>
  <p>Use a top-level <code>agents</code> block to <a href="/docs/pipelines/defining-steps#step-defaults">set defaults</a> for all steps in a pipeline.</p>
</section>
```   

#### Docs Troubleshooting Note  
Use the following example to add a 'troubleshooting note' in the documentation.  

```<section class="Docs__troubleshooting-note">
  <p class="Docs__note__heading">Running each build in it’s own container</p>
  <p>This page references the out-of-date Buildkite Agent v2.</p>
  <p>For docs referencing the Buildkite Agent v3, <a href="/docs/agent/v3/cli_artifact">see the latest version of this document</a>.
</section>
```   

## Screenshots
This information was aggregated by going over the existing screenshots in the documentation repo. Feel free to change or expand it.

### Taking and processing screenshots  
* **Format:** PNG  
* **Ratio:** arbitrary, but **strictly even number of pixels** for both height and width  
* **Size:** the largest possible resolution that makes sense. It's preferable that you take the screenshots on a Mac laptop with a Retina screen. (add division by 2 when publishing if the image is very large, e.g. `width: 2280/2, height: 998/2`).  
* **Border:** no border  
* **Drop shadow:** no  
* **Cursor:** include when relevant  
* **Area highlight selection:** rectangular, no shadow, color either red `#FC2A1C` or blue `#96C3F1` (currently undecided)  
* **Blur:** use to obscure sensitive info like passwords or real email addresses; even, non-pixelated  
* **User info:** blur out everything except for the name  
* **Dummy data:** use Acme Inc as dummy company title  
* **Naming screenshots:** lowercase, words separated by hyphens; number after the title, e.g. "installation-1"  

### Adding screenshots or other images  

> Before you proceed, make sure that both the width and the height of the image are an even number of pixels!  

Steps for adding add an image to a documentation page:  
1. Name the image file (lowercase, separate words using hyphens; add a number to the filename, e.g. 'installation-1' if you are adding several images to the same page)
2. Put the file into the corresponding `images` folder (a folder with the same name as the page you are adding this image to; create such folder if it doesn't exist yet)
3. Compose relevant alt text for the image file using Title case
4. Add your image file to the documentation page using the following code example `<%= image "your-image.png", width: 1110, height: 1110, alt: "Screenshot of Important Feature" %>`.  
For large images/screenshots taken on a retina screen, use `<%= image "your-image.png", width: 1110/2, height: 1110/2, alt: "Screenshot of Important Feature" %>`.  

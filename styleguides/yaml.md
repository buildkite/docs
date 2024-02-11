# Talking about YAML

This document is a part of the larger [Markdown syntax style guide](markdown-syntax-style.md) and it covers the usage of YAML in the Buildkite documentation. Further expansion of this guide is highly welcomed.

## General YAML guidelines

**Where possible, refer to what the YAML represents, such as a command, step, or pipeline, rather than the source itself.**
In other words, describe the abstract meaning or effect of the YAML to be presented, not the literal characters used to declare it.
In this usage, never use code-style text.

✅ Here is an example pipeline configuration…<br>
✅ Add this step to the pipeline…<br>
❌ Add a `command` to `pipeline.yml`…

**If you must refer to YAML source text, avoid using YAML specification terminology.**
Never use *block*, *flow*, *sequence*, *scalar*, and so on because some of them (such as *block*) conflict with product terminology and others are inscrutable or tend toward wordiness (such as *flow style mapping key*).

**Always use code formatting to refer to literal YAML source or its filename.**

✅ The `referer` key is actually spelled like that due to…<br>
❌ Modify pipeline.yml…

**Always use block-style maps and arrays.**
Never use inline maps and arrays.
Block, quoted, and unquoted strings are OK.

✅
```yaml
steps:
  - label: Tests
    command:
      - npm install
      - npm test
```

✅
```yaml
steps:
  - label: "Tests"
    command: >
      npm run test-runner --
      --with=several
      --arguments
      --split-across-lines-for-readability
```

❌
```yaml
{ steps: [ label: "Tests", command: "npm test" ]}
```

## Terms

If you cannot avoiding referring to YAML source directly, use the following terminology.

### Map

Use *map* (noun) to refer only to a collection of key-value pairs (also known as associative arrays, dictionaries, or objects).
The following YAML shows a map consisting of keys (`label`, `command`) and values (`Tests`, `npm test`):

```yaml
label: Tests
command: npm test
```

Never use *map* to refer to a key or value of a collection.
Never use other terms such as *block*, *section*, or *property*.

✅ A command is a map that configures…<br>
❌ Add the `matrix` map to the…

If you must describe a map within a map or other structure, qualify the relationship with *of* or use the term *nested map*.
Do not use the terms *block*, *level*, or the prefix *sub*.

✅ The `retry` attribute of a step is a map of maps…<br>
❌ Add the `matrix` map to the…

### Attribute

Use *attribute* to refer only to a key-value pair as a whole, not the identifier or value alone.
The following YAML shows three attributes: `steps` and its value (an array), `label` and its value (a string), and `command` its value (an array):

```yaml
steps:
  - label: Tests
    command:
      - npm install
      - npm test
```

✅ The `steps` attribute determines…<br>
❌ Add the `steps` attribute to the command step, then on a new line…

### Key and value

Use *key* to refer only to an attribute's identifier and *value* to refer only to the attribute's value.
Remember to use code formatting for literal keys or values.
The following YAML shows one key (`label`) and one value (`Tests`):

```yaml
label: Tests
```

✅ Add the `skip` key to the command step, then on a new line…<br>
✅ Set the value to `true`, `false`, or a string…<br>
❌ Add the skip key to the command step, then on a new line…

### Array

Use *array* to refer only to sequences (also known as lists) and never maps.
The following YAML shows a sequence of strings:

```yaml
- "npm install"
- "npm test"
```

✅ The step attribute consists of an array of step maps…<br>
❌ The attribute contains a list of entries…

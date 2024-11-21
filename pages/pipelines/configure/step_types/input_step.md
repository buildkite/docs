# Input step

An _input_ step is used to collect information from a user.

An input step is functionally identical to a [block step](/docs/pipelines/configure/step-types/block-step), however an input step doesn't create any [dependencies](/docs/pipelines/dependencies) to the steps before and after it.

Input steps block your build from completing, but do not automatically block other steps from running unless they specifically depend upon it.

An input step can be defined in your pipeline settings, or in your [pipeline.yml](/docs/pipelines/configure/defining-steps) file.

```yml
steps:
  - input: "Information please"
    fields:
      - text: "What is the date today?"
        key: "todays-date"
```
{: codeblock-file="pipeline.yml"}

You can add form `fields` to block steps by adding a fields attribute. Block steps with input fields can only be defined using a `pipeline.yml`. There are two field types available: text or select. The select input type displays differently depending on how you configure the options. If you allow people to select multiple options, they display as checkboxes. If you are required to select only one option from six or fewer, they display as radio buttons. Otherwise, the options display in a dropdown menu.

The data you collect from these fields is available to subsequent steps through the [build meta-data](/docs/pipelines/build-meta-data) command.

In this example, the `pipeline.yml` defines an input step with the key `name`. The Bash script then accesses the value of the step using the [meta-data](/docs/agent/v3/cli-meta-data) command.

```yml
  - input: "Who is running this script?"
    fields:
      - text: "Your name"
        key: "name"
  - label: "Run script"
    command: script.sh
```
{: codeblock-file="pipeline.yml"}

```bash
NAME=$(buildkite-agent meta-data get name)
```
{: codeblock-file="script.sh"}

For an example pipeline, see the [Input step example pipeline](https://github.com/buildkite/input-step-example) on GitHub:

<a class="Docs__example-repo" href="https://github.com/buildkite/input-step-example"><span class="detail">:pipeline: Input Step Example Pipeline</span> <span class="repo">github.com/buildkite/input-step-example</span></a>

> 🚧 Don't store sensitive data in input steps
> You shouldn't use input steps to store sensitive information like secrets because the data will be stored in build metadata.

## Input step attributes

Input and block steps have the same attributes available for use.

Optional attributes:

<table data-attributes>
  <tr>
    <td><code>prompt</code></td>
    <td>
      The instructional message displayed in the dialog box when the step is activated.<br>
      <em>Example:</em> <code>"Release to production?"</code><br>
      <em>Example:</em> <code>"Fill out the details for this release"</code>
    </td>
  </tr>
  <tr>
    <td><code>fields</code></td>
    <td>
      A list of input fields required to be filled out before the step will be marked as passed.<br>
      Available input field types: <code>text</code>, <code>select</code>
    </td>
  </tr>
  <tr>
    <td><code>branches</code></td>
    <td>
      The <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch pattern</a> defining which branches will include this input step in their builds.<br>
      <em>Example:</em> <code>"main stable/*"</code>
    </td>
  </tr>
  <tr>
    <td><code>if</code></td>
    <td>
      A boolean expression to restrict the running of the step. See <a href="/docs/pipelines/conditionals">Using conditionals</a> for supported expressions.<br>
      <em>Example:</em> <code>build.message != "skip me"</code>
    </td>
   </tr>
   <tr>
    <td><code>depends_on</code></td>
    <td>
      A list of step keys that this step depends on. This step will only proceed after the named steps have completed. See <a href="/docs/pipelines/dependencies">managing step dependencies</a> for more information.<br>
      <em>Example:</em> <code>"test-suite"</code>
    </td>
   </tr>
   <tr>
    <td><code>key</code></td>
    <td>
	    <p>A unique string to identify the input step.</p>
      <p><em>Example:</em> <code>"test-suite"</code></p>
    </td>
   </tr>
   <tr>
    <td><code>allow_dependency_failure</code></td>
    <td>
      Whether to continue to proceed past this step if any of the steps named in the <code>depends_on</code> attribute fail.<br>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
</table>

```yml
steps:
  - input: "\:rocket\: Release!"
```
{: codeblock-file="pipeline.yml"}

## Text input attributes

> 📘 Line endings
> A text field normalizes line endings to Unix format (<code>\n</code>).

Required attributes:

<table>
  <tr>
    <td><code>key</code></td>
    <td>
      The meta-data key that stores the field's input (using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>)<br>
      The key may only contain alphanumeric characters, slashes, dashes, or underscores.
      <em>Example:</em> <code>"release-name"</code>
    </td>
  </tr>
</table>

```yml
steps:
  - input: "Release information"
    fields:
      - text: "Code Name"
        key: "release-name"
```
{: codeblock-file="pipeline.yml"}

Optional attributes:

<table>
  <tr>
    <td><code>text</code></td>
    <td>
      The text input name.<br>
      <em>Example:</em> <code>"Release Name"</code>
    </td>
  </tr>
  <tr>
    <td><code>hint</code></td>
    <td>
      The explanatory text that is shown after the label.<br>
      <em>Example:</em> <code>"What's the code name for this release? \:name_badge\:"</code>
    </td>
  </tr>
  <tr>
    <td><code>required</code></td>
    <td>
      A boolean value that defines whether the field is required for form submission.<br>
      <em>Default value:</em> <code>true</code>
    </td>
  </tr>
  <tr>
    <td><code>default</code></td>
    <td>
      The value that is pre-filled in the text field.<br>
      <em>Example:</em> <code>"Flying Dolphin"</code>
    </td>
  </tr>
</table>

```yml
steps:
  - input: "Request Release"
    fields:
      - text: "Code Name"
        key: "release-name"
        hint: "What's the code name for this release? \:name_badge\:"
        required: false
        default: "Release #"
```
{: codeblock-file="pipeline.yml"}

## Select input attributes

Required attributes:

<table>
  <tr>
    <td><code>key</code></td>
    <td>
      The meta-data key that stores the field's input (using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>)<br>
      The key may only contain alphanumeric characters, slashes, dashes, or underscores.
      <em>Example:</em> <code>"release-stream"</code>
    </td>
  </tr>
  <tr>
    <td><code>options</code></td>
    <td>
      The list of select field options.<br>
      For 6 or less options they'll be displayed as radio buttons, otherwise they'll be displayed in a dropdown box.<br>
      If selecting multiple options is permitted the options will be displayed as checkboxes.
    </td>
  </tr>
</table>

Each select option has the following _required_ attributes:

<table>
  <tr>
    <td><code>label</code></td>
    <td>
      The text displayed for the option.<br>
      <em>Example:</em> <code>"Stable"</code>
    </td>
  </tr>
  <tr>
    <td><code>value</code></td>
    <td>
      The value to be stored as meta-data (to be later retrieved using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>)<br>
      <em>Example:</em> <code>"stable"</code>
    </td>
  </tr>
</table>

```yml
steps:
  - input: "Request Release"
    fields:
      - select: "Stream"
        key: "release-stream"
        options:
          - label: "Beta"
            value: "beta"
          - label: "Stable"
            value: "stable"
```
{: codeblock-file="pipeline.yml"}

Optional attributes:

<table>
  <tr>
    <td><code>hint</code></td>
    <td>
      The text displayed directly under the select field's label.<br>
      <em>Example:</em> <code>"Which release stream does this belong in? \:fork\:"</code>
    </td>
  </tr>
  <tr>
    <td><code>required</code></td>
    <td>
      A boolean value that defines whether the field is required for form submission.<br>
      When this value is set to <code>false</code> and users can only select one option, the options display in a dropdown menu, regardless of how many options there are.<br>
      <em>Default:</em> <code>true</code>
    </td>
  </tr>
  <tr>
    <td><code>multiple</code></td>
    <td>
      A boolean value that defines whether multiple options may be selected.<br>
      When multiple options are selected, they are delimited in the meta-data field by a line break (<code>\n</code>)<br>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>default</code></td>
    <td>
      The value of the option or options that will be pre-selected.<br>
      When <code>multiple</code> is enabled, this can be an array of values to select by default.<br>
      <em>Example:</em> <code>"beta"</code>
    </td>
  </tr>
</table>

```yml
steps:
  - input: "Release details"
    fields:
      - select: "Stream"
        key: "release-stream"
        hint: "Which release stream does this belong in? \:fork\:"
        required: false
        default: "beta"
        options:
          - label: "Beta"
            value: "beta"
          - label: "Stable"
            value: "stable"
```
{: codeblock-file="pipeline.yml"}

## Input validation

To prevent users from entering invalid text values in input steps  (for example, to gather some deployment information), you can use input validation.

If you associate a regular expression to a field, the field outline will turn red when an invalid value is entered.

To do it, use the following sample syntax:

```yml
steps:
  - input: "Click me!"
    fields:
      - text: Must be hexadecimal
        key: hex
        format: "[0-9a-f]+"
```

The `format` must be a regular expression implicitly anchored to the beginning and end of the input and is functionally equivalent to the [HTML5 pattern attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/pattern).

# Block step

A _block_ step is used to pause the execution of a build and wait on a team member to unblock it using the web or the [API](/docs/apis/rest-api/jobs#unblock-a-job).

A block step is functionally identical to an [input step](/docs/pipelines/configure/step-types/input-step), however a block step creates [implicit dependencies](/docs/pipelines/configure/dependencies) to the steps before and after it. Note that explicit dependencies specified by `depends_on` take precedence over implicit dependencies; subsequent steps will run when the step they depend on passes, without waiting for `block` or `wait` steps, unless those are also explicit dependencies.

A block step can be defined in your pipeline settings, or in your [pipeline.yml](/docs/pipelines/configure/defining-steps) file.

Once all steps before the block have completed, the pipeline will pause and wait for a team member to unblock it. Clicking on a block step in the Buildkite web UI opens a dialog box asking if you'd like to continue.

```yaml
steps:
  - block: "\:rocket\: Are we ready?"
```

{: codeblock-file="pipeline.yml"}

<%= image "unblock_button.png", width: 2048/2, height: 2048/2, alt: "Screenshot of button to press to unblock a block step" %>

<%= image "confirm_modal.png", width: 2048/2, height: 2048/2, alt: "Screenshot of a basic block step" %>

You can add form `fields` to block steps by adding a fields attribute. Block steps with input fields can only be defined using a `pipeline.yml`. There are two field types available: text or select. The select input type displays differently depending on how you configure the options. If you allow people to select multiple options, they display as checkboxes. If you are required to select only one option from six or fewer, they display as radio buttons. Otherwise, the options display in a dropdown menu.

The data you collect from these fields is then available to subsequent steps in the pipeline in the [build meta-data](/docs/pipelines/configure/build-meta-data).

In this example, the `pipeline.yml` defines an input step with the key `release-name`. The Bash script then accesses the value of the step using the [meta-data](/docs/agent/v3/cli-meta-data) command.

<%= image "release_modal_input.png", alt: "Screenshot of a block step with input fields" %>

```yaml
- block: "Release"
  prompt: "Fill out the details for release"
  fields:
    - text: "Release Name"
      key: "release-name"
```

{: codeblock-file="pipeline.yml"}

```bash
RELEASE_NAME=$(buildkite-agent meta-data get release-name)
```

{: codeblock-file="script.sh"}

For a complete example pipeline, including dynamically generated input fields, see the [Block step example pipeline](https://github.com/buildkite/block-step-example/blob/main/.buildkite/pipeline.yml) on GitHub:

<a class="Docs__example-repo" href="https://github.com/buildkite/block-step-example"><span class="detail">:pipeline: Block Step Example Pipeline</span> <span class="repo">github.com/buildkite/block-step-example</span></a>

## Block step attributes

Input and block steps have the same attributes available for use.

Optional attributes:

<table data-attributes>
  <tr>
    <td><code>prompt</code></td>
    <td>
      The instructional message displayed in the dialog box when the unblock step is activated.<br/>
      <em>Example:</em> <code>"Release to production?"</code><br/>
      <em>Example:</em> <code>"Fill out the details for this release"</code>
    </td>
  </tr>
  <tr>
    <td><code>fields</code></td>
    <td>
      A list of input fields required to be filled out before unblocking the step.<br/>
      Available input field types: <code>text</code>, <code>select</code>
    </td>
  </tr>
    <tr>
    <td><code>blocked_state</code></td>
    <td>
      The state that the build is set to when the build is blocked by this block step. The default is <code>passed</code>. When the <code>blocked_state</code> of a block step is set to <code>failed</code>, the step that triggered it will be stuck in the <code>running</code> state until it is manually unblocked. If you're using GitHub, you can also <a href="/docs/pipelines/source-control/github#customizing-commit-statuses">configure which GitHub status</a> to use for blocked builds on a per-pipeline basis.<br/>
      <em>Default:</em> <code>passed</code><br/>
      <em>Values:</em> <code>passed</code>, <code>failed</code>, <code>running</code>
    </td>
  </tr>
  <tr>
    <td><code>allowed_teams</code></td>
    <td>
      A list of teams that are permitted to unblock this step, whose values are a list of one or more team slugs or IDs. If this field is specified, a user must be a member of one of the teams listed in order to unblock.<br/>
      The use of <code>allowed_teams</code> replaces the need for write access to the pipeline, meaning a member of an allowed team with read-only access may unblock the step. Learn more about this attribute in the <a href="#permissions">Permissions</a> section.<br/>
      <em>Example:</em> <code>["deployers", "approvers", "b50084ea-4ed1-405e-a204-58bde987f52b"]</code><br/>
    </td>
  </tr>
  <tr>
    <td><code>branches</code></td>
    <td>
      The <a href="/docs/pipelines/configure/workflows/branch-configuration#branch-pattern-examples">branch pattern</a> defining which branches will include this block step in their builds.<br/>
      <em>Example:</em> <code>"main stable/*"</code>
    </td>
  </tr>
  <tr>
    <td><code>if</code></td>
    <td>
      A boolean expression that omits the step when false. See <a href="/docs/pipelines/configure/conditionals">Using conditionals</a> for supported expressions.<br/>
      <em>Example:</em> <code>build.message != "skip me"</code>
    </td>
  </tr>
  <tr>
    <td><code>depends_on</code></td>
    <td>
      A list of step keys that this step depends on. This step will only proceed after the named steps have completed. See <a href="/docs/pipelines/configure/dependencies">managing step dependencies</a> for more information.<br/>
      <em>Example:</em> <code>"test-suite"</code>
    </td>
   </tr>
  <tr>
    <td><code>key</code></td>
    <td>
      A unique string to identify the block step.<br/>
      Keys cannot have the same pattern as a UUID (<code>xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx</code>).<br/>
      <em>Example:</em> <code>"test-suite"</code><br/>
      <em>Alias:</em> <code>identifier</code>
    </td>
   </tr>
   <tr>
    <td><code>allow_dependency_failure</code></td>
    <td>
      Whether to continue to proceed past this step if any of the steps named in the <code>depends_on</code> attribute fail.<br/>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
</table>

```yaml
steps:
  - block: "\:rocket\: Release!"
```

{: codeblock-file="pipeline.yml"}

## Text field attributes

> 📘 Line endings
> A text field normalizes line endings to Unix format (<code>\n</code>).

Required attributes:

<table>
  <tr>
    <td><code>key</code></td>
    <td>
      The meta-data key that stores the field's input (using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>).<br/>
      The key may only contain alphanumeric characters, slashes, dashes, or underscores.<br/>
      <em>Example:</em> <code>"release-name"</code>
    </td>
  </tr>
</table>

```yaml
steps:
  - block: "Request Release"
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
      The text input name.<br/>
      <em>Example:</em> <code>"Release Name"</code>
    </td>
  </tr>
  <tr>
    <td><code>hint</code></td>
    <td>
      The explanatory text that is shown after the label.<br/>
      <em>Example:</em> <code>"What's the code name for this release? \:name_badge\:"</code>
    </td>
  </tr>
  <tr>
    <td><code>required</code></td>
    <td>
      A boolean value that defines whether the field is required for form submission.<br/>
      <em>Default:</em> <code>true</code>
    </td>
  </tr>
  <tr>
    <td><code>default</code></td>
    <td>
      The value that is pre-filled in the text field.<br/>
      <em>Example:</em> <code>"Flying Dolphin"</code>
    </td>
  </tr>
  <tr>
    <td><code>format</code></td>
    <td>
      A regular expression used for <a href="#input-validation">input validation</a> that indicates invalid input.<br/>
      <em>Example:</em> <code>"[a-zA-Z]+"</code>
    </td>
  </tr>
</table>

```yaml
steps:
  - block: "Request Release"
    fields:
      - text: "Code Name"
        key: "release-name"
        hint: "What's the code name for this release? \:name_badge\:"
        required: false
        default: "Release #"
```

{: codeblock-file="pipeline.yml"}

## Select field attributes

Required attributes:

<table>
  <tr>
    <td><code>key</code></td>
    <td>
      The meta-data key that stores the field's input (using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>).<br/>
      The key may only contain alphanumeric characters, slashes, dashes, or underscores.<br/>
      <em>Example:</em> <code>"release-stream"</code>
    </td>
  </tr>
  <tr>
    <td><code>options</code></td>
    <td>
      The list of select field options.<br/>
      For six or fewer options they'll be displayed as radio buttons, otherwise they'll be displayed in a dropdown box.<br/>
      If selecting multiple options is permitted, the options will be displayed as checkboxes.
    </td>
  </tr>
</table>

```yaml
steps:
  - block: "Request Release"
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
      The text displayed directly under the select field's label.<br/>
      <em>Example:</em> <code>"Which release stream does this belong in? \:fork\:"</code>
    </td>
  </tr>
  <tr>
    <td><code>required</code></td>
    <td>
      A boolean value that defines whether the field is required for form submission.<br/>
      When this value is set to <code>false</code> and users can only select one option, the options display in a dropdown menu, regardless of how many options there are.<br/>
      <em>Default:</em> <code>true</code>
    </td>
  </tr>
  <tr>
    <td><code>multiple</code></td>
    <td>
      A boolean value that defines whether multiple options may be selected.<br/>
      When multiple options are selected, they are delimited in the meta-data field by a comma (<code>,</code>).<br/>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>default</code></td>
    <td>
      The value of the option or options that will be pre-selected.<br/>
      When <code>multiple</code> is enabled, this can be an array of values to select by default.<br/>
      <em>Example:</em> <code>"beta"</code>
    </td>
  </tr>
</table>

```yaml
steps:
  - block: "Deploy To"
    fields:
      - select: "Regions"
        key: "deploy-regions"
        hint: "Which regions should we deploy this to? \:earth_asia\:"
        required: true
        multiple: true
        default:
          - "na"
          - "eur"
          - "asia"
          - "aunz"
        options:
          - label: "North America"
            value: "na"
          - label: "Europe"
            value: "eur"
          - label: "Asia"
            value: "asia"
          - label: "Oceania"
            value: "aunz"
```
{: codeblock-file="pipeline.yml"}

Each select option has the following _required_ attributes:

<table>
  <tr>
    <td><code>label</code></td>
    <td>
      The text displayed for the option.<br/>
      <em>Example:</em> <code>"Stable"</code>
    </td>
  </tr>
  <tr>
    <td><code>value</code></td>
    <td>
      The value to be stored as meta-data (to be later retrieved using the <a href="/docs/agent/v3/cli-meta-data">buildkite-agent meta-data command</a>).<br/>
      <em>Example:</em> <code>"stable"</code>
    </td>
  </tr>
</table>

## Permissions

To unblock a block step, a user must either have write access to the pipeline, or where the [`allowed_teams` attribute](#block-step-attributes) is specified, the user must belong to one of the allowed teams. When `allowed_teams` is specified, a user who has write access to the pipeline but is not a member of any of the allowed teams will not be permitted to unblock the step.

The `allowed_teams` attribute serves as a useful way to restrict unblock permissions to a subset of users without restricting the ability to create builds. Conversely, this attribute is also useful for granting unblock permissions to users _without_ also granting the ability create builds.

```yml
- block: "Release"
  prompt: "Fill out the details for release"
  allowed_teams:
    - "approvers"
  fields:
    - text: "Release Name"
      key: "release-name"
```
{: codeblock-file="pipeline.yml"}

## Passing block step data to other steps

Before you can do anything with the values from a block step, you need to store the data using the Buildkite meta-data store.

Use the `key` attribute in your block step to store values from the text or select fields in meta-data:

```yaml
steps:
  - block: "Request Release"
    fields:
      - text: "Code Name"
        key: "release-name"
```

{: codeblock-file="pipeline.yml"}

You can access the stored meta-data after the block step has passed. Use the `buildkite-agent meta-data get` command to retrieve your data:

```shell
buildkite-agent meta-data get "release-name"
```

> 🚧
> Meta-data cannot be interpolated directly from the <code>pipeline.yml</code> at runtime. The meta-data store can only be accessed from within a command step.

In the below example, the script uses the `buildkite-agent` meta-data command to retrieve the meta-data and print it to the log:

```bash
#!/bin/bash

RELEASE_NAME="$(buildkite-agent meta-data get "release-name")"
echo "Release name: $RELEASE_NAME"
```

### Passing meta-data to trigger steps

When passing meta-data values to trigger steps you need to delay adding the trigger step to the pipeline until after the block step has completed; this can be done using [dynamic pipelines](/docs/agent/v3/cli-pipeline), and works around the lack of runtime meta-data interpolation.

You can modify a trigger step to dynamically upload itself to a pipeline as follows:

1. Move your trigger step from your `pipeline.yml` file into a script. The below example script is stored in a file named `.buildkite/trigger-deploy.sh`:

    ```bash
    #!/bin/bash

    set -euo pipefail

    # Set up a variable to hold the meta-data from your block step
    RELEASE_NAME="$(buildkite-agent meta-data get "release-name")"

    # Create a pipeline with your trigger step
    PIPELINE="steps:
      - trigger: \"deploy-pipeline\"
        label: \"Trigger deploy\"
        build:
          meta_data:
            release-name: $RELEASE_NAME
    "

    # Upload the new pipeline and add it to the current build
    echo "$PIPELINE" | buildkite-agent pipeline upload
    ```

1. Replace the old trigger step in your `pipeline.yml` with a dynamic pipeline upload:

    _Before_ the `pipeline.yml` file with the trigger step:

    ```yaml
    steps:
      - block: "\:shipit\:"
        fields:
          - text: "Code Name"
            key: "release-name"
      - trigger: "deploy-pipeline"
        label: "Trigger Deploy"
    ```
    <!-- {: codeblock-file="pipeline.yml"} -->

    _After_ the `pipeline.yml` file dynamically uploading the trigger step:

    ```yaml
    steps:
      - block: "\:shipit\:"
        fields:
          - text: "Code Name"
            key: "release-name"
      - command: ".buildkite/trigger-deploy.sh"
        label: "Prepare Deploy Trigger"
    ```
    <!-- {: codeblock-file="pipeline.yml"} -->

The command step added in the above example will upload the trigger step and add it to the end of our pipeline at runtime.

In the pipeline you're triggering, you will be able to use the meta-data that you have passed through as if it was set during the triggered build.

## Metadata validation handling

When using block steps with form fields, it's important to understand how the `required` and the `default` attributes interact with metadata validation.

Setting `required: false` only affects the UI. If you also set `default: ""`, the metadata key will exist with an empty string. Some `buildkite-agent` commands (for example, `buildkite-agent meta-data set`) reject empty or whitespace-only values and fail at runtime.

Recommended approach:

- Set the field `required: true` (no default), or
- Keep the field optional (`required: false`) but provide a non-empty default.

## Input validation

To prevent users from entering invalid text values in block steps (for example, to gather some deployment information), you can use input validation.

If you associate a regular expression with a field, the field outline will turn red when an invalid value is entered.

To implement input validation, use the following sample syntax:

```yaml
steps:
  - block: "Click me!"
    fields:
      - text: "Must be hexadecimal"
        key: hex
        format: "[0-9a-f]+"
```

The `format` must be a regular expression implicitly anchored to the beginning and end of the input and is functionally equivalent to the [HTML5 pattern attribute](https://developer.mozilla.org/en-US/docs/Web/HTML/Attributes/pattern).

## Block steps interacting with wait steps

<%= render_markdown partial: 'pipelines/configure/step_types/block_wait' %>

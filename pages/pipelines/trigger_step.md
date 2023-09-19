# Trigger step

A *trigger* step creates a build on another pipeline.

You can use trigger steps to separate your test and deploy pipelines, or to create build dependencies between pipelines.


A trigger step can be defined in your pipeline settings, or in your [pipeline.yml](/docs/pipelines/defining-steps) file, by setting the `trigger` attribute to the the [slug of the pipeline you want to trigger](#trigger).

```yml
steps:
  - trigger: deploy-pipeline
```
{: codeblock-file="pipeline.yml"}

## Permissions

All builds created by a trigger step will have the same author as the parent build. This user must:

* be a member of your organization
* have a verified email address

If you have [Teams](/docs/team-management/permissions) enabled in your organization, *one* of the following conditions must be met:

* The authoring user must have 'Build' permission on *every* pipeline that will be triggered
* The triggering build has no creator and no unblocker, *and* the source pipeline and the target pipeline share a team that can 'Build'

If neither condition is true, the build will fail, and builds on subsequent pipelines will not be triggered.

If your triggering pipelines are started by an API call or a webhook, it might not be clear whether the triggering user has access to the triggered pipeline, which will cause your build to fail. To prevent that from happening, make sure that all of your GitHub user accounts that are triggering builds are [connected to Buildkite accounts](/docs/integrations/github#connecting-buildkite-and-github).

## Trigger step attributes

_Required attributes:_

<table data-attributes data-attributes-required id="trigger">
  <tr>
    <td><code>trigger</code></td>
    <td>
      The slug of the pipeline to create a build. You can find it in the URL of your pipeline, and it corresponds to the name of the pipeline, converted to <a href="https://en.wikipedia.org/wiki/Letter_case#Kebab_case">kebab-case</a>.<br>
      <em>Example:</em> <code>"another-pipeline"</code>
    </td>
  </tr>
</table>


_Optional attributes:_

<table data-attributes>
  <tr>
    <td><code>build</code></td>
    <td>
      An optional map of attributes for the triggered build.
      Available attributes: <code>branch</code>, <code>commit</code>, <code>env</code>, <code>message</code>, <code>meta_data</code>
    </td>
  </tr>
  <tr>
    <td><code>label</code></td>
    <td>
      The label that will be displayed in the pipeline visualisation in Buildkite. Supports emoji.<br>
      <em>Example:</em> <code>"\:rocket\: Deploy"</code><br>
    </td>
  </tr>
  <tr>
    <td><code>async</code></td>
    <td>
      If set to <code>true</code> the step will immediately continue, regardless of the success of the triggered build. If set to <code>false</code> the step will wait for the triggered build to complete and continue only if the triggered build passed.<br>
      <p>Note that when <code>async</code> is set to <code>true</code>, as long as the triggered build starts, the original pipeline will show that as successful. The original pipeline does not get updated after subsequent steps or after the triggered build completes.<br>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>branches</code></td>
    <td>
      The <a href="/docs/pipelines/branch-configuration#branch-pattern-examples">branch pattern</a> defining which branches will include this step in their builds.<br>
      <em>Example:</em> <code>"main stable/*"</code>
    </td>
  </tr>
  <tr>
    <td><code>if</code></td>
    <td>
      A boolean expression that omits the step when false. See <a href="/docs/pipelines/conditionals">Using conditionals</a> for supported expressions.<br>
      <em>Example:</em> <code>build.message != "skip me"</code>
    </td>
  </tr>
  <tr>
    <td><code>depends_on</code></td>
    <td>
      A list of step keys that this step depends on. This step will only run after the named steps have completed. See <a href="/docs/pipelines/dependencies">managing step dependencies</a> for more information.<br>
      <em>Example:</em> <code>"test-suite"</code>
    </td>
   </tr>
   <tr>
    <td><code>allow_dependency_failure</code></td>
    <td>
      Whether to continue to run this step if any of the steps named in the <code>depends_on</code> attribute fail.<br>
      <em>Default:</em> <code>false</code>
    </td>
  </tr>
  <tr>
    <td><code>skip</code></td>
    <td>
      Whether to skip this step or not. Passing a string provides a reason for skipping this command. Passing an empty string is equivalent to <code>false</code>.
      Note: Skipped steps will be hidden in the pipeline view by default, but can be made visible by toggling the 'Skipped jobs' icon.<br>
      <em>Example:</em> <code>true</code><br>
      <em>Example:</em> <code>false</code><br>
      <em>Example:</em> <code>"My reason"</code>
    </td>
  </tr>
  <tr>
    <td><code>soft_fail</code></td>
    <td>
      When <code>true</code>, failure of the triggered build will not cause the triggering build to fail.<br>
      <em>Default:</em> <code>false</code><br>
    </td>
  </tr>
</table>

_Optional_ `build` _attributes:_

<table>
  <tr>
    <td><code>message</code></td>
    <td>
      The message for the build. Supports emoji.<br>
      <em>Default:</em> the label of the trigger step.<br>
      <em>Example:</em> <code>"Triggered build"</code><br>
    </td>
  </tr>
  <tr>
    <td><code>commit</code></td>
    <td>
      The commit hash for the build.<br>
      <em>Default:</em> <code>"HEAD"</code><br>
      <em>Example:</em> <code>"ca82a6d"</code><br>
    </td>
  </tr>
  <tr>
    <td><code>branch</code></td>
    <td>
      The branch for the build.<br>
      <em>Default:</em> The triggered pipeline's default branch.<br>
      <em>Example:</em> <code>"production"</code><br>
    </td>
  </tr>
  <tr>
    <td><code>meta_data</code></td>
    <td>
      A map of <a href="/docs/pipelines/build-meta-data">meta-data</a> for the build.<br>
      <em>Example:</em> <code>release-version: "1.1"</code>
    </td>
  </tr>
  <tr>
    <td><code>env</code></td>
    <td>
      A map of <a href="/docs/pipelines/environment-variables">environment variables</a> for the build.<br>
      <em>Example:</em> <code>RAILS_ENV: "test"</code>
    </td>
  </tr>
</table>

```yml
- trigger: "data-generator"
  label: "\:package\: Generate data"
  build:
    meta_data:
      release-version: "1.1"
```
{: codeblock-file="pipeline.yml"}

## Environment variables

You can use [environment variable substitution](/docs/agent/v3/cli-pipeline#environment-variable-substitution) to set attribute values:

```yml
- trigger: "app-deploy"
  label: "\:rocket\: Deploy"
  branches: "main"
  async: true
  build:
    message: "${BUILDKITE_MESSAGE}"
    commit: "${BUILDKITE_COMMIT}"
    branch: "${BUILDKITE_BRANCH}"
```
{: codeblock-file="pipeline.yml"}

To pass through pull request information to the triggered build, pass through the branch and pull request environment variables:

```yml
- trigger: "app-sub-pipeline"
  label: "Sub-pipeline"
  build:
    message: "${BUILDKITE_MESSAGE}"
    commit: "${BUILDKITE_COMMIT}"
    branch: "${BUILDKITE_BRANCH}"
    env:
      BUILDKITE_PULL_REQUEST: "${BUILDKITE_PULL_REQUEST}"
      BUILDKITE_PULL_REQUEST_BASE_BRANCH: "${BUILDKITE_PULL_REQUEST_BASE_BRANCH}"
      BUILDKITE_PULL_REQUEST_REPO: "${BUILDKITE_PULL_REQUEST_REPO}"
```
{: codeblock-file="pipeline.yml"}

To set environment variables on the build created by the trigger step, use the `env` attribute:

```yml
- trigger: "release-binaries"
  label: "\:package\: Release"
  build:
    env:
      RELEASE_STREAM: "${RELEASE_STREAM:-stable}"
```
{: codeblock-file="pipeline.yml"}

## Triggering specific steps in a pipeline

While you cannot trigger only a specific step in a pipeline, you can use [conditionals](/docs/pipelines/conditionals) or [dynamic pipelines](/docs/pipelines/defining-steps#dynamic-pipelines) to achieve a similar effect.


An example using conditionals might look like this:

* Testing for [BUILDKITE_SOURCE](/docs/pipelines/environment-variables) `=='trigger_job'` to find out if the build was triggered by a trigger step
* Testing for [BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG](/docs/pipelines/environment-variables#BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG) to find out which pipeline triggered the build
* Custom [environment variables](#environment-variables) passed to the triggered build

In the target pipeline, to run the command step only if the build was triggered by a specific pipeline, you might use something like this:

```yml
steps:
    - command: ./scripts/tests.sh
      if: build.source == 'trigger_job' && build.env('BUILDKITE_TRIGGERED_FROM_BUILD_ID') == 'the_trigering_pipeline'

```
{: codeblock-file="pipeline.yml"}

If you also want the command step to run when the build was not triggered by the specific pipeline, you might need to do the opposite, and set conditions on the steps that you don't want to run when the build is triggered:

```yml
steps:
    - command: ./scripts/tests.sh
      if: build.source != 'trigger_job'

```
{: codeblock-file="pipeline.yml"}

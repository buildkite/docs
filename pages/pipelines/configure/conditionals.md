# Using conditionals

Using conditionals, you can run builds or steps only when specific conditions are met. Define [boolean conditions using C-like expressions](#variable-and-syntax-reference).

You can define conditionals at the step level in your `pipeline.yml` or at the pipeline level in your Buildkite version control provider settings.

## Conditionals in pipelines

You can have complete control over when to trigger pipeline builds by using conditional expressions to filter incoming webhooks. You need to define conditionals in the pipeline's **Settings** page for your repository provider to run builds only when expressions evaluate to `true`. For example, to run only when a pull request is targeting the main branch:

<%= image "conditionals.png", width: 864, height: 298, alt: "Conditional Filtering settings" %>

Pipeline-level build conditionals are evaluated before any other build trigger settings. If both a conditional and a branch filter are present, both filters must pass for a build to be created – first the pipeline-level limiting filter and then the conditional filter.

Conditionals are supported in [Bitbucket](/docs/pipelines/source-control/bitbucket), [Bitbucket Server](/docs/pipelines/source-control/bitbucket-server), [GitHub](/docs/pipelines/source-control/github), [GitHub Enterprise](/docs/pipelines/source-control/github-enterprise), and [GitLab](/docs/pipelines/source-control/gitlab) (including GitLab Community and GitLab Enterprise). You can add a conditional on your pipeline's **Settings** page in the Buildkite interface or using the REST API.

> 📘 Evaluating conditionals
> Conditional expressions are evaluated at pipeline upload, not at step runtime.

## Conditionals in steps

Use the `if` attribute in your step definition to conditionally run a step.

In the below example, the `tests` step will only be run if the build message does not contain the string "skip tests".

```yml
steps:
  - command: ./scripts/tests.sh
    label: tests
    if: build.message !~ /skip tests/
```
{: codeblock-file="pipeline.yml"}

The `if` attribute can be used in any type of step, and with any of the supported expressions and parameters. However, it cannot be used at the same time as the `branches` attribute.

Be careful when defining conditionals within YAML. Many symbols have special meaning in YAML and will change the type of a value. You can avoid this by quoting your conditional as a string.

```yml
steps:
  - command: ./scripts/tests.sh
    label: tests
    if: "!build.pull_request.draft"
```
{: codeblock-file="pipeline.yml"}

Multi-line conditionals can be added with the `|` character, and avoid the need for quotes:

```yml
steps:
  - command: ./scripts/tests.sh
    label: tests
    if: |
      // Do not run when the message contains "skip tests"
      //   and
      // Only run on feature branches
      build.message !~ /skip tests/ &&
        build.branch =~ /^feature\//
```
{: codeblock-file="pipeline.yml"}

Since `if` conditions are evaluated at the time of the pipeline upload, it's not possible to use the `if` attribute to conditionally run a step based on the result of another step.

> 🚧 Plugin execution and conditionals
> Step-level `if` conditions only prevent commands from running but they _do not_ affect plugins. Plugins run during the job lifecycle, before the conditional is evaluated. To conditionally run plugins, use either [group steps](#conditionally-running-plugins-with-group-steps) or [dynamic pipeline uploads](#conditionally-running-plugins-with-dynamic-uploads).

To run a step based on the result of another step, upload a new pipeline based on the `if` condition set up in the [command step](/docs/pipelines/configure/step-types/command-step) like in the example below:

```yml
steps:
  - label: "Validation check"
    command: ./scripts/validation_tests.sh
    key: "validation-check"
  - label: "Run regression only if validation check is passed"
    depends_on: "validation-check"
    command: |
      if [ $$(buildkite-agent step get "outcome" --step "validation-check") == "passed" ]; then
         cat <<- YAML | buildkite-agent pipeline upload
         steps:
           - label: "Run Regression"
             command: ./scripts/regression_tests.sh
      YAML
      fi
```
{: codeblock-file="pipeline.yml"}

## Conditional notifications

To trigger [Build notifications](/docs/pipelines/configure/notifications#conditional-notifications) only under certain conditions, use the same `if` syntax as in your [Steps](/docs/pipelines/configure/conditionals#conditionals-in-steps).

For example, the following email notification will only be triggered if the build passes:

```yaml
notify:
  - email: "dev@acmeinc.com"
    if: build.state == "passed"
```
{: codeblock-file="pipeline.yml"}

Note that conditional expressions on the build state are only available at the pipeline level. You can't use them at the step level.

## Conditionally running plugins with group steps

To conditionally run plugins, use [group steps](/docs/pipelines/configure/step-types/group-step) rather than step-level `if` conditions. Group's conditional is evaluated before any steps within the group are created, which prevents plugin from executing entirely:

```yaml
steps:
  - group: "Docker Build"
    if: build.env("DOCKER_PASSWORD") != null
    steps:
      - label: "Build and push image"
        command: "docker build -t myapp ."
        plugins:
          - docker#v5.13.0:
              image: "docker:latest"
          - docker-login#v3.0.0:
              username: myuser
              password-env: DOCKER_PASSWORD
```
{: codeblock-file="pipeline.yml"}

## Conditionally running plugins with dynamic uploads

For complex conditional logic, use dynamic pipeline uploads with conditional logic running in a shell script before the steps with plugins are uploaded:

```yaml
steps:
  - label: "Docker Build"
    command: |
      if [ -n "${DOCKER_PASSWORD}" ]; then
        echo "Docker credentials found, uploading build steps..."
        cat <<EOF | buildkite-agent pipeline upload
      steps:
        - label: "Build and push image"
          command: "docker build -t myapp ."
          plugins:
            - docker#v5.13.0:
                image: "docker:latest"
            - docker-login#v3.0.0:
                username: myuser
                password-env: DOCKER_PASSWORD
      EOF
      else
        echo "No Docker credentials found, skipping build"
      fi
```
{: codeblock-file="pipeline.yml"}

## Conditionals and the broken state

Jobs become `broken` when their configuration prevents them from running. This might be because their [branch configuration](/docs/pipelines/configure/workflows/branch-configuration) doesn't match the build's branch, or because a conditional returned `false`. This is distinct from `skipped` jobs, which might happen if a newer build is started and build skipping is enabled. A rough explanation is that jobs break because of something _inside_ the build and are skipped by something _outside_ the build.

## Variable and syntax reference

Evaluate expressions made up of [boolean operators](#variable-and-syntax-reference-operator-syntax) and [variables](#variable-and-syntax-reference-variables).

### Operator syntax

The following expressions are supported by the `if` attribute.

 <table>
 	<tbody>
 		<tr>
 			<td>Comparators</td>
 			<td><code>== != =~ !~</code></td>
 		</tr>
 		<tr>
 			<td>Logical operators</td>
 			<td><code>|| &&</code></td>
 		</tr>
 		<tr>
 			<td>Array operators</td>
 			<td><code>includes</code></td>
 		</tr>
 		<tr>
 			<td>Integers</td>
 			<td><code>12345</code></td>
 		</tr>
 		<tr>
 			<td>Strings</td>
 			<td><code>'feature-branch' "feature-branch"</code></td>
 		</tr>
		<tr>
			<td>Literals</td>
 			<td><code>true false null</code></td>
 		</tr>
 		<tr>
 			<td>Parentheses</td>
 			<td><code>( )</code></td>
 		</tr>
 		<tr>
 			<td>Regular expressions</td>
 			<td><code>/^v1\.0/</code></td>
 		</tr>
 		<tr>
 			<td>Prefixes</td>
 			<td><code>!</code></td>
 		</tr>
 		<tr>
 			<td>Comments</td>
 			<td><code>// This is a comment</code></td>
 		</tr>
 	</tbody>
 </table>

> 🚧 Formatting regular expressions
> When using regular expressions in conditionals, the regular expression must be on the right hand side, and the use of the `$` anchor symbol must be escaped to avoid [environment variable substitution](/docs/agent/cli/reference/pipeline#environment-variable-substitution). For example, to match branches ending in `"/feature"` the conditional statement would be `build.branch =~ /\/feature$$/`.

### Variables

The following variables are supported by the `if` attribute. Note that you cannot use [Build Meta-data](/docs/pipelines/configure/build-meta-data) in conditional expressions.

> 🚧 Unverified commits
> Note that GitHub accepts <a href="https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification">unsigned commits</a>, including information about the commit author and passes them along to webhooks, so you should not rely on these for authentication unless you are confident that all of your commits are trusted.

<table>
<tbody>
	<tr>
		<td><code>build.author.email</code></td>
		<td><code>String</code></td>
		<td>The <strong><a href="#unverified-commits">unverified</a></strong> email address of the user who authored the build's commit</td>
	</tr>
	<tr>
		<td><code>build.author.id</code></td>
		<td><code>String</code></td>
		<td>The <strong><a href="#unverified-commits">unverified</a></strong> ID of the user who authored the build's commit</td>
	</tr>
	<tr>
		<td><code>build.author.name</code></td>
		<td><code>String</code></td>
		<td>The <strong><a href="#unverified-commits">unverified</a></strong> name of the user who authored the build's commit</td>
	</tr>
	<tr>
		<td><code>build.author.teams</code></td>
		<td><code>Array</code></td>
		<td>An <strong><a href="#unverified-commits">unverified</a></strong> array of the team/s which the user who authored the build's commit is a member of</td>
	</tr>
	<tr>
		<td><code>build.branch</code></td>
		<td><code>String</code></td>
		<td>The branch on which this build is created from</td>
	</tr>
	<tr>
		<td><code>build.commit</code></td>
		<td><code>String</code></td>
		<td>The commit number of the commit the current build is based on</td>
	</tr>
	<tr>
		<td><code>build.creator.email</code></td>
		<td><code>String</code></td>
		<td><p>The email address of the user who created the build. The value differs depending on how the build was created:</p>
			<ul>
				<li><strong>Buildkite dashboard:</strong> Set based on who manually created the build.</li>
				<li><strong>GitHub webhook:</strong> Set from the <strong><a href="#unverified-commits">unverified</a></strong> HEAD commit.</li>
				<li><strong>Webhook:</strong> Set based on which user is attached to the API Key used.</li>
			</ul>
  			<p>For conditionals to use this variable, the user set must be a verified Buildkite user.</p>
		</td>
	</tr>
	<tr>
		<td><code>build.creator.id</code></td>
		<td><code>String</code></td>
		<td><p>The ID of the user who created the build. The value differs depending on how the build was created:</p>
			<ul>
				<li><strong>Buildkite dashboard:</strong> Set based on who manually created the build.</li>
				<li><strong>GitHub webhook:</strong> Set from the <strong><a href="#unverified-commits">unverified</a></strong> HEAD commit.</li>
				<li><strong>Webhook:</strong> Set based on which user is attached to the API Key used.</li>
			</ul>
  			<p>For conditionals to use this variable, the user set must be a verified Buildkite user.</p>
		</td>
	</tr>
	<tr>
		<td><code>build.creator.name</code></td>
		<td><code>String</code></td>
		<td><p>The name of the user who created the build. The value differs depending on how the build was created:</p>
			<ul>
				<li><strong>Buildkite dashboard:</strong> Set based on who manually created the build.</li>
				<li><strong>GitHub webhook:</strong> Set from the <strong><a href="#unverified-commits">unverified</a></strong> HEAD commit.</li>
				<li><strong>Webhook:</strong> Set based on which user is attached to the API Key used.</li>
			</ul>
  			<p>For conditionals to use this variable, the user set must be a verified Buildkite user.</p>
		</td>
	</tr>
	<tr>
		<td><code>build.creator.teams</code></td>
		<td><code>Array</code></td>
		<td><p>An array of the teams which the user who created the build is a member of. The value differs depending on how the build was created:</p>
			<ul>
				<li><strong>Buildkite dashboard:</strong> Set based on who manually created the build.</li>
				<li><strong>GitHub webhook:</strong> Set from the <strong><a href="#unverified-commits">unverified</a></strong> HEAD commit.</li>
				<li><strong>Webhook:</strong> Set based on which user is attached to the API Key used.</li>
			</ul>
  			<p>For conditionals to use this variable, the user set must be a verified Buildkite user.</p>
		</td>
	</tr>
	<tr>
		<td><code>build.env()</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>This function returns the value of the environment passed as the first argument if that variable is set, or <code>null</code> if the environment variable is not set.<br>
		<code>build.env()</code> works with variables you've defined, and the following <code>BUILDKITE_*</code> variables:<br>
		<code>BUILDKITE_BRANCH</code><br>
		<code>BUILDKITE_TAG</code><br>
		<code>BUILDKITE_MESSAGE</code><br>
		<code>BUILDKITE_COMMIT</code><br>
		<code>BUILDKITE_PIPELINE_SLUG</code><br>
		<code>BUILDKITE_PIPELINE_NAME</code><br>
		<code>BUILDKITE_PIPELINE_ID</code><br>
		<code>BUILDKITE_ORGANIZATION_SLUG</code><br>
		<code>BUILDKITE_TRIGGERED_FROM_BUILD_ID</code><br>
		<code>BUILDKITE_TRIGGERED_FROM_BUILD_NUMBER</code><br>
		<code>BUILDKITE_TRIGGERED_FROM_BUILD_PIPELINE_SLUG</code><br>
		<code>BUILDKITE_REBUILT_FROM_BUILD_ID</code><br>
		<code>BUILDKITE_REBUILT_FROM_BUILD_NUMBER</code><br>
		<code>BUILDKITE_REPO</code><br>
		<code>BUILDKITE_PULL_REQUEST</code><br>
		<code>BUILDKITE_PULL_REQUEST_BASE_BRANCH</code><br>
		<code>BUILDKITE_PULL_REQUEST_REPO</code><br>
		<code>BUILDKITE_MERGE_QUEUE_BASE_BRANCH</code><br>
		<code>BUILDKITE_MERGE_QUEUE_BASE_COMMIT</code><br>
		<code>BUILDKITE_GITHUB_DEPLOYMENT_ID</code><br>
		<code>BUILDKITE_GITHUB_DEPLOYMENT_TASK</code><br>
		<code>BUILDKITE_GITHUB_DEPLOYMENT_ENVIRONMENT</code><br>
		<code>BUILDKITE_GITHUB_DEPLOYMENT_PAYLOAD</code><br>
	  </td>
	</tr>
	<tr>
		<td><code>build.id</code></td>
		<td width="20%"><code>String</code></td>
		<td>The ID of the current build</td>
	</tr>
	<tr>
		<td><code>build.message</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The current build's message</td>
	</tr>
	<tr>
		<td><code>build.number</code></td>
		<td><code>Integer</code></td>
		<td>The number of the current build</td>
	</tr>
	<tr>
		<td><code>build.pull_request.base_branch</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The base branch that the pull request is targeting, otherwise <code>null</code> if the branch is not a pull request</td>
	</tr>
	<tr>
		<td><code>build.pull_request.id</code></td>
		<td><code>String</code>, <code>null</code></td>
 		<td>The number of the pull request, otherwise <code>null</code> if the branch is not a pull request</td>
	</tr>
	<tr>
		<td><code>build.pull_request.draft</code></td>
		<td><code>Boolean</code>, <code>null</code></td>
		<td>If the pull request is a draft, otherwise <code>null</code> if the branch is not a pull request or the provider doesn't support draft pull requests</td>
	</tr>
	<tr>
		<td><code>build.pull_request.labels</code></td>
		<td><code>Array</code></td>
		<td>An array of label names attached to the pull request</td>
	</tr>
	<tr>
		<td><code>build.pull_request.repository</code></td>
		<td><code>String</code>, <code>null</code></td>
 		<td>The repository URL of the pull request, otherwise <code>null</code> if the branch is not a pull request</td>
	</tr>
	<tr>
		<td><code>build.pull_request.repository.fork</code></td>
		<td><code>Boolean</code>, <code>null</code></td>
		<td>If the pull request comes from a forked repository, otherwise <code>null</code> if the branch is not a pull request</td>
	</tr>
	<tr>
		<td><code>build.merge_queue.base_branch</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>If a merge queue build, the target branch which the merge queue build will be merged into</td>
	</tr>
	<tr>
		<td><code>build.merge_queue.base_commit</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>If a merge queue build, the <a href="https://git-scm.com/docs/git-merge-base" target="_blank" rel="nofollow">merge base</a> of the proposed merge commit (<code>build.commit</code>)</td>
	</tr>
	<tr>
		<td><code>build.source</code></td>
		<td><code>String</code></td>
		<td>The source of the event that created the build<br><em>Available sources:</em> <code>ui</code>, <code>api</code>, <code>webhook</code>, <code>trigger_job</code>, <code>schedule</code></td>
	</tr>
	<tr>
		<td><code>build.state</code></td>
		<td><code>String</code></td>
		<td>The state the current build is in<br><em>Available states:</em> <code>started</code>, <code>scheduled</code>, <code>running</code>, <code>passed</code>, <code>failed</code>, <code>failing</code>, <code>started_failing</code>, <code>blocked</code>, <code>canceling</code>, <code>canceled</code>, <code>skipped</code>, <code>not_run</code></td>
	</tr>
	<tr>
		<td><code>build.tag</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The tag associated with the commit the current build is based on</td>
	</tr>
	<tr>
		<td><code>pipeline.default_branch</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The default branch of the pipeline the current build is from</td>
	</tr>
	<tr>
		<td><code>pipeline.id</code></td>
		<td><code>String</code></td>
		<td>The ID of the pipeline the current build is from</td>
	</tr>
	<tr>
		<td><code>pipeline.repository</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The repository of the pipeline the current build is from</td>
	</tr>
	<tr>
		<td><code>pipeline.slug</code></td>
		<td><code>String</code></td>
		<td>The slug of the pipeline the current build is from</td>
	</tr>
	<tr>
		<td><code>organization.id</code></td>
		<td><code>String</code></td>
		<td>The ID of the organization the current build is running in</td>
	</tr>
	<tr>
		<td><code>organization.slug</code></td>
		<td><code>String</code></td>
		<td>The slug of the organization the current build is running in</td>
	</tr>
</tbody>
</table>

> 🚧 Using `build.env()` with custom environment variables
> To access custom environment variables with the `build.env()` function, ensure that the <a href="https://buildkite.com/changelog/32-defining-pipeline-build-steps-with-yaml">YAML pipeline steps editor</a> has been enabled in the Pipeline Settings menu.

The following step variables are also available for <a href="#conditional-notifications">conditional notifications</a> only.

<table>
<tbody>
	<tr>
		<td><code>step.id</code></td>
		<td width="20%"><code>String</code></td>
		<td>The ID of the current step</td>
	</tr>
	<tr>
		<td><code>step.key</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The key of the current step</td>
	</tr>
	<tr>
		<td><code>step.label</code></td>
		<td><code>String</code>, <code>null</code></td>
		<td>The label of the current step</td>
	</tr>
	<tr>
		<td><code>step.type</code></td>
		<td><code>String</code></td>
		<td>The type of the current step<br><em>Available types:</em> <code>command</code>, <code>wait</code>, <code>input</code>, <code>trigger</code>, <code>group</code></td>
	</tr>
	<tr>
		<td><code>step.state</code></td>
		<td><code>String</code></td>
		<td>The state of the current step<br><em>Available states:</em> <code>ignored</code>, <code>waiting_for_dependencies</code>, <code>ready</code>, <code>running</code>, <code>failing</code>, <code>finished</code></td>
	</tr>
	<tr>
		<td><code>step.outcome</code></td>
		<td><code>String</code></td>
		<td>The outcome of the current step<br><em>Available outcomes:</em> <code>neutral</code>, <code>passed</code>, <code>soft_failed</code>, <code>hard_failed</code>, <code>errored</code></td>
	</tr>
</tbody>
</table>

## Example expressions

To run only when the branch is `main` or `production`:

```js
build.branch == "main" || build.branch == "production"
```

To run only when the branch is not `production`:

```js
build.branch != "production"
```

To run only when the branch starts with `features/`:

```js
build.branch =~ /^features\//
```

To run only when the branch ends with `/release-123`, such as `feature/release-123`:

```js
build.branch =~ /\/release-123\$/
```

To run only when building a tag:

```js
build.tag != null
```

To run only when building a tag beginning with a `v` and ends with a `.0`, such as `v1.0`:

```js
// Using the tag variable
build.tag =~ /^v[0-9]+\.0\$/

// Using the env function
build.env("BUILDKITE_TAG") =~ /^v[0-9]+\.0\$/
```

To run only if the message doesn't contain `[skip tests]`, case insensitive:

```js
build.message !~ /\[skip tests\]/i
```

To run only if the build was created from a schedule:

```js
build.source == "schedule"
```

To run when the value of `CUSTOM_ENVIRONMENT_VARIABLE` is `value`:

```js
build.env("CUSTOM_ENVIRONMENT_VARIABLE") == "value"
```

To run when the **[unverified](#unverified-commits)** build creator is in the `deploy` team:

```js
build.creator.teams includes "deploy"
```

To run only non-draft pull requests:

```js
!build.pull_request.draft
```

To run only on merge queue builds targeting the `main` branch:

```js
build.merge_queue.base_branch == "main"
```

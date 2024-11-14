# Other Git servers

If your Git server isn't an integrated repository provider, then you can trigger builds using Git hook scripts and the Buildkite REST API.

This guide explains how to trigger builds when you push to a Git server.
For example, if you're using a proprietary Git server, then you can trigger builds on push with a post-receive hook.
This method can be adapted for other Git events or for running Buildkite builds from arbitrary scripts and services.

## Before you start

To follow along with the steps in this guide, you need the following:

- An [API access token](/docs/apis/managing-api-tokens)

- The ability to run server-side Git hooks

    If your Git server is hosted on a platform that restricts or prohibits running arbitrary scripts, such as GitHub, then this approach won't work.

- Familiarity with the concepts of executable shell scripts, Buildkite pipelines and builds, and REST APIs

## Git hooks at a glance

Git runs hooks — specially named executables — at certain Git lifecycle events, such as before a commit or after a push.

Git runs executables found in:

- The `hooks` directory of a [bare repository](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefbarerepositoryabarerepository) (more common on servers)
- The `.git/hooks` directory of a repository with a [worktree](https://git-scm.com/docs/gitglossary#Documentation/gitglossary.txt-aiddefworktreeaworktree) (less common on servers)
- A directory set by the [`core.hooksPath`](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corehooksPath) configuration variable

For example, after a push to the bare repository at the path `/repos/demo-repo/`, Git checks for the existence of an executable file `/repos/demo-repo/hooks/post-receive`.
If it exists, it runs the file with arguments containing details about the push.

The post-recieve hook is a convenient place to trigger builds using the Buildkite REST API.

## Step 1: Create a pipeline

If you haven't already, create [a pipeline to run](https://buildkite.com/docs/pipelines/defining-steps) for the repository.

After you've created the pipeline, make a note of the organization slug and pipeline slug in the pipeline URL.
You need both for the next step.
For example, in the pipeline settings URL `https://buildkite.com/example-org/git-pipeline-demo/settings`, `example-org` and `git-pipeline-demo` are the organization and pipeline slugs, respectively.

## Step 2: Create a Git hook to react to pushes

On your Git server, create a `post-receive` hook script in your repository's `hooks` directory that calls the Buildkite REST API's [Create a build](https://buildkite.com/docs/apis/rest-api/builds#create-a-build) endpoint.

For example, in a bare repository, create a file named `hooks/post-receive` with the following contents:

```bash
#!/usr/bin/env bash

BUILDKITE_ORG_SLUG="example-org"
BUILDKITE_PIPELINE_SLUG="git-hook-demo"

BUILDKITE_PAYLOAD_FORMAT='{
  "commit": "%s",
  "branch": "%s",
  "message": "%s",
  "author": { "name": "%s", "email": "%s" }
}\n'

while read -r _oldrev newrev ref; do
  branch=$(git rev-parse --abbrev-ref "$ref")
  author=$(git log -1 HEAD --format="format:%an")
  email=$(git log -1 HEAD --format="format:%ae")
  message=$(git log -1 HEAD --format="format:%B")

  curl -X POST \
    "https://api.buildkite.com/v2/organizations/$BUILDKITE_ORG_SLUG/pipelines/$BUILDKITE_PIPELINE_SLUG/builds" \
    -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "$(printf "$BUILDKITE_PAYLOAD_FORMAT" "$newrev" "$branch" "$message" "$author" "$email")"
done
```

To use this script:

- Set the `BUILDKITE_API_TOKEN` environment variable to an [API access token](/docs/apis/managing-api-tokens).

    The token is a privileged secret.
    A best practice for secret storage is to use your own secrets storage service, such as [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) or [Hashicorp Vault](https://www.vaultproject.io).

- Set a valid `BUILDKITE_ORG_SLUG` and `BUILDKITE_PIPELINE_SLUG`, or replace them with environment variables.
- Make the file executable (for example, in the `hooks` directory, run `chmod +x post-receive`).

You can also adapt this script for your application.
For example, you can modify it to selectively trigger builds for certain branches, trigger multiple builds, save log output, or to respond to other Git events.

## Step 3: Test the hook

To test the hook, push to the Git server.

If you've configured your hook successfully, a new build is scheduled for the specified pipeline.

## Learn more

- For more on how to control builds with the REST API, read [Builds API](/docs/apis/rest-api/builds).
- For a complete list of Git hooks, read [githooks](https://git-scm.com/docs/githooks) in the [Git reference](https://git-scm.com/docs) (or run `man githooks`).
- For an overview of Git hooks, read the [Customizing Git - Git Hooks](https://git-scm.com/book/en/Customizing-Git-Git-Hooks) chapter of [Pro Git](https://git-scm.com/book/en/).
